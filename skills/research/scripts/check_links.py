#!/usr/bin/env python3
"""Check every http(s) URL cited in the research notes. Standard library only.

Usage: python check_links.py <notes-dir-or-file> [--out links.md] [--timeout 15]

Writes a markdown table (default: links.md next to the notes dir) and prints a summary.
Statuses: ok (2xx/3xx) · blocked (401/403/429 — the page exists but refuses bots; not dead) ·
dead (404/410, other 4xx/5xx, DNS or connection failure) · error (timeout, TLS…).
"""
import argparse
import concurrent.futures
import pathlib
import re
import ssl
import sys
import urllib.error
import urllib.request

URL_RE = re.compile(r"https?://[^\s<>\"'`)\]|]+")
UA = "Mozilla/5.0 (compatible; link-check/1.0)"
BLOCKED = {401, 403, 405, 429, 999}


def collect(target: pathlib.Path):
    files = [target] if target.is_file() else sorted(target.rglob("*.md"))
    found = {}
    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for url in URL_RE.findall(text):
            url = url.rstrip(".,;:")
            found.setdefault(url, set()).add(f.name)
    return found


def fetch(url: str, timeout: int):
    ctx = ssl.create_default_context()
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=method, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as r:
                return "ok", str(r.status)
        except urllib.error.HTTPError as e:
            if method == "HEAD":
                continue  # many servers refuse HEAD; retry with GET
            if e.code in BLOCKED:
                return "blocked", str(e.code)
            return "dead", str(e.code)
        except urllib.error.URLError as e:
            if method == "HEAD":
                continue
            reason = str(getattr(e, "reason", e))
            dead = any(s in reason.lower() for s in ("getaddrinfo", "name or service", "refused", "nodename"))
            return ("dead" if dead else "error"), reason[:80]
        except Exception as e:  # timeout, TLS, bad URL
            if method == "HEAD":
                continue
            return "error", type(e).__name__
    return "error", "no response"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("target")
    ap.add_argument("--out")
    ap.add_argument("--timeout", type=int, default=15)
    a = ap.parse_args()

    target = pathlib.Path(a.target).expanduser()
    if not target.exists():
        sys.exit(f"not found: {target}")
    out = pathlib.Path(a.out).expanduser() if a.out else (
        (target if target.is_dir() else target.parent).parent / "links.md")

    urls = collect(target)
    results = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(fetch, u, a.timeout): u for u in urls}
        for fut in concurrent.futures.as_completed(futures):
            results[futures[fut]] = fut.result()

    order = {"dead": 0, "error": 1, "blocked": 2, "ok": 3}
    rows = sorted(results.items(), key=lambda kv: (order[kv[1][0]], kv[0]))
    lines = ["# Link check", "", "| Status | Detail | URL | Cited in |", "|---|---|---|---|"]
    for url, (status, detail) in rows:
        lines.append(f"| {status} | {detail} | {url} | {', '.join(sorted(urls[url]))} |")
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")

    counts = {}
    for status, _ in results.values():
        counts[status] = counts.get(status, 0) + 1
    summary = ", ".join(f"{k} {v}" for k, v in sorted(counts.items(), key=lambda kv: order[kv[0]]))
    print(f"{len(urls)} URLs: {summary or 'none'} -> {out}")


if __name__ == "__main__":
    main()
