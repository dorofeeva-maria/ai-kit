"""Move task folders and update Markdown references to them.

Use --workspace to select the workspace. The optional --config JSON file can contain
"overrides" (task key -> old entry name in notes/ -> path relative to the task folder)
"legacy_stage" (an object with "label", "review_from", and "review_marker"), and
"staged_keys" (a regular expression, matched against the entire key). Slugs outside
that pattern and project setup task START retain their notes/ directory.
The label excludes its trailing colon. The legacy status rule applies to an old
task file without a status line (for example, stage 8 or later with a handoff marker).
"""
import argparse
import subprocess
import filecmp
import json
import os
from pathlib import Path, PureWindowsPath
import re
import shutil
import stat
import sys
from tempfile import NamedTemporaryFile
from urllib.parse import quote, unquote


STATUSES = ("backlog", "in-work", "review", "done", "dropped")
STATUS_LINE = re.compile(r"^status:[ \t]*([a-z -]+?)(?=[ \t]*(?:·|\r?$))", re.MULTILINE)
PART = re.compile(r"(?:^|-)([A-Z]\d+|part\d+(?:-[a-z]+)?|mr\d+)(?=-|\.|$)")
RULES = (
    (r"^(research|related-tasks|data-facts|check-research|check-links)\b|-compare\b", "research"),
    (r"^(journeys|mockups|board|design|check-mockups|check-journey|check-design|check-look-mockups)\b", "design"),
    (r"^(plan|check-plan)\b", "plan"),
    (r"^e2e\b", "e2e"),
)
PLAN = re.compile(r"^(plan|check-plan)\b")
MARKDOWN_LINK = re.compile(r"(?P<prefix>\]\(|^\[[^\]\n]+\]:[ \t]*)(?P<path>[^\s()<>#]+)", re.MULTILINE)


def read(path):
    with path.open(encoding="utf-8", newline="") as stream:
        return stream.read()


def write(path, content):
    with NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
    try:
        with temporary.open("w", encoding="utf-8", newline="") as stream:
            stream.write(content)
        shutil.copymode(path, temporary)
        temporary.replace(path)
    finally:
        if temporary.exists():
            temporary.chmod(stat.S_IREAD | stat.S_IWRITE)
            temporary.unlink()


def portable_name(name):
    return (
        isinstance(name, str)
        and bool(name)
        and name[-1] not in ". "
        and not any(ord(char) < 32 or char in '/\\:*?"<>|' for char in name)
        and not PureWindowsPath(name).is_reserved()
    )


def check_key(key):
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", key) or not portable_name(key):
        raise ValueError(f"Invalid task key: {key!r}")


def load_config(path):
    if path is None:
        return {}, None, None
    config = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(config, dict) or config.keys() - {"overrides", "legacy_stage", "staged_keys"}:
        raise ValueError("Expected a JSON object with optional overrides, legacy_stage, and staged_keys")
    overrides = config.get("overrides", {})
    if not isinstance(overrides, dict):
        raise ValueError("Expected an object for overrides")
    for key, entries in overrides.items():
        check_key(key)
        if not isinstance(entries, dict):
            raise ValueError(f"Expected an object for overrides.{key}")
        for name, target in entries.items():
            if (
                not portable_name(name)
                or not isinstance(target, str)
                or not all(portable_name(part) for part in target.split("/"))
                or target.split("/", 1)[0].lower() == "notes"
            ):
                raise ValueError(f"Invalid override for {key}: {name!r} -> {target!r}")
    stage = config.get("legacy_stage")
    if stage is not None and (
        not isinstance(stage, dict)
        or stage.keys() != {"label", "review_from", "review_marker"}
        or type(stage["review_from"]) is not int
        or not isinstance(stage["label"], str)
        or not stage["label"]
        or not isinstance(stage["review_marker"], str)
        or not stage["review_marker"]
    ):
        raise ValueError("Expected legacy_stage with label, review_from, and review_marker")
    staged_keys = config.get("staged_keys")
    if staged_keys is not None and not isinstance(staged_keys, str):
        raise ValueError("Expected a regular expression string for staged_keys")
    return overrides, stage, re.compile(staged_keys) if staged_keys is not None else None


def path_kind(path):
    try:
        info = path.lstat()
    except FileNotFoundError:
        return None
    reparse = getattr(info, "st_file_attributes", 0) & stat.FILE_ATTRIBUTE_REPARSE_POINT
    if reparse or stat.S_ISLNK(info.st_mode):
        raise ValueError(f"Refusing to follow link or junction: {path}")
    if stat.S_ISDIR(info.st_mode):
        return "directory"
    if stat.S_ISREG(info.st_mode):
        return "file"
    raise ValueError(f"Unsupported file type: {path}")


def status_of(content, legacy_stage):
    current = STATUS_LINE.search(content)
    if current:
        status = current[1].strip().replace(" ", "-")
        if status not in STATUSES:
            raise ValueError(f"Unknown task status: {current[1]!r}")
        return status
    if legacy_stage:
        stage = re.search(r"^" + re.escape(legacy_stage["label"]) + r":[ \t]*(\d+)([^\r\n]*)", content, re.MULTILINE)
        if stage and int(stage[1]) >= legacy_stage["review_from"] and legacy_stage["review_marker"] in stage[2]:
            return "review"
    return "in-work"


def set_status(content, status):
    line = f"status: {status.replace('-', ' ')}"
    if STATUS_LINE.search(content):
        return STATUS_LINE.sub(line, content, count=1)
    newline = "\r\n" if "\r\n" in content else "\n"
    title, _, body = content.partition(newline)
    if title.startswith("# "):
        return title + newline + line + newline + body
    return line + newline + content


def stage_folder(name):
    part = PART.search(name)
    if part and not PLAN.match(name):
        return part[1]
    return next((folder for pattern, folder in RULES if re.search(pattern, name)), "other")


def plan_layout(tasks, key, requested_status, overrides, legacy_stage, staged_keys):
    stage_notes = key != "START" and (staged_keys is None or staged_keys.fullmatch(key))
    current_dirs = []
    for status in STATUSES:
        parent = tasks / status
        if path_kind(parent) not in (None, "directory"):
            raise ValueError(f"Expected a directory: {parent}")
        current = parent / key
        kind = path_kind(current)
        if kind == "directory":
            current_dirs.append(current)
        elif kind:
            raise ValueError(f"Expected a directory: {current}")
    # A retry may find the destination directory created by the first attempt.
    complete_dirs = [path for path in current_dirs if path_kind(path / f"{key}.md") == "file"]
    if len(complete_dirs) > 1:
        raise ValueError(f"{key} appears in more than one status folder")
    legacy = tasks / key
    roots = current_dirs.copy()
    if key not in STATUSES and path_kind(legacy) == "directory":
        roots.append(legacy)
    flat_roots = (tasks, tasks / "done")
    primary = [
        parent / f"{key}.md" for parent in (*roots, *flat_roots)
        if path_kind(parent / f"{key}.md") == "file"
    ]
    if not primary:
        raise ValueError(f"No task file found for {key}")
    content = read(primary[0])
    status = requested_status
    if status is None:
        if complete_dirs:
            status = complete_dirs[0].parent.name
        elif primary[0].parent == tasks / "done":
            status = "done"
        else:
            status = status_of(content, legacy_stage)
    destination = tasks / status / key
    moves = {}
    root_moves = {root: destination for root in roots if root != destination}
    notes = []
    for root in roots:
        for entry in root.iterdir():
            if entry.name == "notes" and stage_notes and path_kind(entry) == "directory":
                notes.append(entry)
            elif entry.parent != destination:
                moves[entry] = destination / entry.name
    for root in flat_roots:
        for old, new in ((f"{key}.md", f"{key}.md"), (f"{key}-plan.md", "plan.md"), (f"{key}-notes", "notes")):
            source = root / old
            kind = path_kind(source)
            if kind == "directory" and new == "notes" and stage_notes:
                notes.append(source)
                continue
            if kind:
                moves[source] = destination / new

    entries = [entry for directory in notes for entry in sorted(directory.iterdir())]
    overridden = overrides.get(key, {})
    dirs = {
        entry.name for entry in entries
        if entry.name not in overridden and path_kind(entry) == "directory"
    }
    reports = {entry.stem for entry in entries if entry.suffix == ".md" and path_kind(entry) == "file"}
    for entry in entries:
        name = entry.name
        folder = stage_folder(name)
        if name in overridden:
            target = overridden[name]
        elif name in dirs:
            associated = sorted(report for report in reports if re.fullmatch(re.escape(name) + r"(?:-\d+)?", report))
            target = f"{folder}/{associated[-1] if associated else name}"
        elif entry.suffix == ".md" and (entry.stem in dirs or re.sub(r"-\d+$", "", entry.stem) in dirs):
            target = f"{folder}/{entry.stem}/{name}"
        else:
            target = f"{folder}/{name}"
        moves[entry] = destination / target
    return destination, content, moves, root_moves, notes


def preflight(moves, tasks):
    claims = {}
    file_moves = {}
    dirs = set()

    def claim(destination, kind, source=None):
        previous = claims.get(destination)
        actual = path_kind(destination)
        if previous and previous[0] != kind or actual and actual != kind:
            raise ValueError(f"Conflicting file and directory at {destination}")
        if kind == "file":
            for existing in (destination if actual else None, previous[1] if previous else None):
                if existing is not None and not filecmp.cmp(source, existing, shallow=False):
                    raise ValueError(f"Different files would occupy {destination}: {existing} and {source}")
        claims[destination] = (kind, source)

    def inspect(source, destination):
        if source == destination or destination.is_relative_to(source):
            raise ValueError(f"Move would overlap its source: {source} -> {destination}")
        for parent in reversed(destination.parents):
            if parent.is_relative_to(tasks):
                claim(parent, "directory")
        kind = path_kind(source)
        claim(destination, kind, source)
        if kind == "directory":
            dirs.add(source)
            for entry in source.iterdir():
                inspect(entry, destination / entry.name)
        else:
            file_moves[source] = destination

    for source, destination in moves.items():
        inspect(source, destination)
    return file_moves, dirs, claims


def markdown_path(target, parent):
    return quote(os.path.relpath(target, parent).replace("\\", "/"), safe="/")


def prepare_link_updates(tasks, task, moves, file_moves, status_content):
    if not moves:
        if status_content is None:
            return {}
        task_file = task / f"{task.name}.md"
        original = read(task_file)
        return {task_file: (original, status_content)} if original != status_content else {}
    workspace = tasks.parent
    full_paths = {old.relative_to(workspace).as_posix(): new for old, new in moves.items()}
    old_paths = sorted(full_paths, key=len, reverse=True)
    full_pattern = re.compile(
        r"(?<![\w./-])(" + "|".join(re.escape(old) for old in old_paths) + r")(?![\w.-])"
    ) if old_paths else None
    aliases = {}
    for old, new in moves.items():
        if old.parent.name == "notes" or old.parent.name.endswith("-notes"):
            names = [old.name, f"notes/{old.name}", f"{old.parent.name}/{old.name}"]
        elif old.parent in (tasks, tasks / "done") and old.suffix == ".md":
            names = [old.name]
        else:
            continue
        for name in names:
            aliases.setdefault(name, set()).add(new)
    strings = [name for name in sorted(aliases, key=len, reverse=True) if len(aliases[name]) == 1]
    legacy_pattern = re.compile(
        r"(?<![\w./-])("
        + "|".join(re.escape(name) + (r"(?=/)" if "." not in Path(name).name else "") for name in strings)
        + r")(?![\w.-])"
    ) if strings else None
    updates = {}
    for root, dirs, filenames in os.walk(tasks):
        root = Path(root)
        for name in dirs.copy():
            try:
                path_kind(root / name)
            except ValueError:
                dirs.remove(name)
        for name in filenames:
            if not name.endswith(".md"):
                continue
            old_doc = root / name
            try:
                if path_kind(old_doc) != "file":
                    continue
                original = read(old_doc)
            except (ValueError, FileNotFoundError):
                if old_doc in file_moves:
                    raise
                continue
            new_doc = file_moves.get(old_doc, old_doc)
            content = status_content if status_content is not None and new_doc == task / f"{task.name}.md" else original

            def replace_relative(match):
                ref = unquote(match["path"])
                if ref.startswith(("/", "\\")) or ":" in ref:
                    return match[0]
                workspace_relative = ref.startswith("tasks/")
                old_parent = workspace if workspace_relative else old_doc.parent
                old_target = Path(os.path.normpath(old_parent / ref))
                if not old_target.is_relative_to(workspace):
                    return match[0]
                for candidate in (old_target, *old_target.parents):
                    if candidate in moves:
                        new_target = moves[candidate] / old_target.relative_to(candidate)
                        new_parent = workspace if workspace_relative else new_doc.parent
                        return match["prefix"] + markdown_path(new_target, new_parent)
                if not workspace_relative and new_doc != old_doc and old_target.exists():
                    return match["prefix"] + markdown_path(old_target, new_doc.parent)
                return match[0]

            if legacy_pattern and new_doc.is_relative_to(task):
                # Protect links for their path-aware pass. Bare legacy references elsewhere in
                # the same task are relative to the document after it moves.
                start = 0
                chunks = []
                for match in MARKDOWN_LINK.finditer(content):
                    chunks.append(replace_aliases(content[start:match.start()], legacy_pattern, aliases, new_doc))
                    relative = replace_relative(match)
                    targets = aliases.get(unquote(match["path"]), set())
                    if relative == match[0] and len(targets) == 1:
                        relative = match["prefix"] + markdown_path(next(iter(targets)), new_doc.parent)
                    chunks.append(relative)
                    start = match.end()
                chunks.append(replace_aliases(content[start:], legacy_pattern, aliases, new_doc))
                content = "".join(chunks)
            else:
                content = MARKDOWN_LINK.sub(replace_relative, content)
            if full_pattern:
                content = full_pattern.sub(lambda match: full_paths[match[1]].relative_to(workspace).as_posix(), content)
            if content != original:
                updates[new_doc] = (original, content)
    return updates


def replace_aliases(content, pattern, aliases, document):
    return pattern.sub(
        lambda match: os.path.relpath(next(iter(aliases[match[1]])), document.parent).replace("\\", "/"),
        content,
    )


def move_task(tasks, key, status, overrides, legacy_stage, staged_keys):
    task, content, moves, roots, notes = plan_layout(tasks, key, status, overrides, legacy_stage, staged_keys)
    file_moves, dirs, claims = preflight(moves, tasks)
    updates = prepare_link_updates(
        tasks, task, {**roots, **moves}, file_moves, set_status(content, status) if status else None
    )
    created_dirs = []
    removed_dirs = []
    moved_files = []
    updated_files = []
    # Move the task file last so an interrupted process can still identify the source task.
    ordered = sorted(file_moves.items(), key=lambda move: move[1] == task / f"{key}.md")
    try:
        for destination, (kind, _) in claims.items():
            if kind == "directory" and not destination.exists():
                destination.mkdir()
                created_dirs.append(destination)
        for source, destination in ordered:
            duplicate = destination.exists()
            if duplicate:
                if not filecmp.cmp(source, destination, shallow=False):
                    raise ValueError(f"Destination changed while moving {source}: {destination}")
                source.unlink()
            else:
                source.rename(destination)
            moved_files.append((source, destination, duplicate))
        for path, (original, updated) in updates.items():
            if read(path) != original:
                raise ValueError(f"File changed while updating links: {path}")
            write(path, updated)
            updated_files.append(path)
        for directory in sorted(dirs | roots.keys() | set(notes), key=lambda path: len(path.parts), reverse=True):
            directory.rmdir()
            removed_dirs.append(directory)
    except (OSError, ValueError) as error:
        try:
            for directory in reversed(removed_dirs):
                directory.mkdir(parents=True, exist_ok=True)
            for path in reversed(updated_files):
                original, updated = updates[path]
                if read(path) != updated:
                    raise ValueError(f"File changed during rollback: {path}")
                write(path, original)
            for source, destination, duplicate in reversed(moved_files):
                source.parent.mkdir(parents=True, exist_ok=True)
                if source.exists():
                    raise ValueError(f"Source path changed during rollback: {source}")
                if duplicate:
                    shutil.copy2(destination, source)
                else:
                    destination.rename(source)
            for directory in reversed(created_dirs):
                directory.rmdir()
        except (OSError, ValueError) as recovery_error:
            raise ValueError(f"{error}; could not fully restore the move: {recovery_error}") from recovery_error
        raise
    return task


RELEASED = {"review", "done", "dropped"}


def bash_path():
    """Git's own bash on Windows (a bare "bash" there may be WSL's, which cannot read C:/ paths)."""
    if os.name == "nt":
        try:
            exec_path = subprocess.run(["git", "--exec-path"], capture_output=True, text=True).stdout.strip()
            candidate = Path(exec_path).parents[2] / "bin" / "bash.exe"
            if candidate.is_file():
                return str(candidate)
        except (OSError, IndexError):
            pass
    return "bash"


def release_trees(workspace, key):
    """Remove the task's trees once the task leaves work; keep any tree that would lose work."""
    folder = workspace / "worktrees" / key
    if not folder.is_dir():
        return
    helper = Path(__file__).with_name("git-worktree.sh")
    for tree in sorted(folder.iterdir()):
        if not (tree / ".git").is_file():
            continue
        result = subprocess.run(
            [bash_path(), helper.as_posix(), "release", tree.as_posix(), "origin"],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        line = (result.stdout.strip().splitlines() or [f"kept|{tree}|{result.stderr.strip()}"])[-1]
        state, _, rest = line.partition("|")
        path, _, reason = rest.partition("|")
        name = Path(path).name or tree.name
        print(f"  tree {name}: {state}" + (f" ({reason})" if reason else ""))
    if folder.is_dir() and not any(folder.iterdir()):
        folder.rmdir()
    elif folder.is_dir():
        left = ", ".join(sorted(p.name for p in folder.iterdir()))
        print(f"  worktrees/{key} kept: {left}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workspace", type=Path, required=True)
    parser.add_argument("--config", type=Path)
    parser.add_argument("--status", type=lambda value: value.replace(" ", "-"), choices=STATUSES)
    parser.add_argument("--keep-trees", action="store_true",
                        help="leave the task's worktrees when it moves to review, done or dropped")
    parser.add_argument("keys", metavar="KEY", nargs="+")
    args = parser.parse_args()
    try:
        tasks = args.workspace.resolve() / "tasks"
        if path_kind(tasks) != "directory":
            raise ValueError(f"No tasks directory at {tasks}")
        overrides, legacy_stage, staged_keys = load_config(args.config)
        for key in args.keys:
            check_key(key)
        for key in args.keys:
            task = move_task(tasks, key, args.status, overrides, legacy_stage, staged_keys)
            print(f"{key}: {task.relative_to(tasks.parent).as_posix()}")
            if args.status in RELEASED and not args.keep_trees:
                release_trees(tasks.parent, key)
    except (OSError, ValueError, re.error) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
