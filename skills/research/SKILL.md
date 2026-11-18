---
name: research
description: Research any topic (not only code) from fresh, cross-checked sources and return only verified findings — a short answer, a claim table, or an HTML artifact when the human will use a large result. Three depths (quick / standard / deep) picked by the request; blind researchers in parallel, a link check by script, an independent checker that tries to refute claims, a writer. Use for "research", "find out", "compare options", "what exists for X", "is X still true", and whenever another skill or agent needs gathered and checked information.
---

# research — verified findings, not a reasoning trail

You are the **coordinator**. You run in the calling session (subagents cannot start subagents, so
coordination stays here). Keep your context clean: you do not search, read sources or write the
findings yourself — researchers, the checker and the writer do; you read only their short replies
and the final text. Files carry the knowledge between steps, not your memory.

**Every agent runs in the background** — researchers (all in one message), the compressor, the
checker and the writer. Wait for each one's completion notice before the step that needs it; do not
poll and do not do its work meanwhile. So the session stays free when `task`, `project`,
`brainstorm` or `decide` calls this skill.

**Run it in the main session, never inside a subagent.** Claude Code refuses a subagent's Write of
a report-like markdown file (`findings…`, `report…`, `summary…`, `analysis…`): subagents return
their results as text. So the agents that produce the merged findings and the final report — the
compressor and the writer — **return their text, and you save it** with Write, verbatim, without
retelling it. Researchers' notes and the checker's verdicts are working files the agents write
themselves. Never try to get around the refusal (another name, Bash, a script): it is the
harness's rule, and it is how a subagent's result is meant to reach you.

Paths below: `<skill>` is this skill's base directory (shown when the skill loads); `<run>` is the
run folder you create in step 2.

## Inputs

From the request or the caller (an orchestrator, a brainstorm, another skill):

- **question** — required.
- **purpose** — only if the caller passes it. Researchers never get it unless the caller says they
  may: a researcher who knows what answer is wanted finds it.
- **depth** — `quick` / `standard` / `deep`; if not given, you pick (step 1).
- **own data** — on by default: the place's own knowledge (the current repo or workspace, any
  knowledge base the place's instructions name, connectors in this session). **Off** when the
  request asks for an independent or fresh outside view, or the caller says so.
- **consumer** — the human, or an agent. Decides the output form (step 9).
- **mode** — `ask` (default when a human is present) or `autonomous` (only when explicitly asked, or
  when called by an agent: then questions come back with defaults instead of being asked).

## 1. Read the request, pick the depth

**Ask only when needed.** Ask the human (AskUserQuestion, a batch, each with a default) only when
the request is vague, uncertain, under-explained, contradicts itself or raises a doubt that would
change what gets searched. Never ask the date — take today's date yourself
(`python -c "import datetime;print(datetime.date.today())"`). In `autonomous` mode, write the
assumptions you made at the top of the brief instead of asking.

**Depth** — say your choice in one line; the human or caller may override:

| | quick | standard | deep |
|---|---|---|---|
| For | one fact, one check, a definition | a comparison, "what exists", a decision with a few options | a big decision, a new field, contested facts, ideas to be built on |
| Perspectives (step 3) | — | yes | yes |
| Researchers | 1 | 2–4 by aspect | 2–4 by aspect + subquestion tree |
| Compression (step 6) | — | yes | yes |
| Link check (step 5) | yes | yes | yes |
| Checker (step 7) | key claims and dates | refutes claims + dates | + several critic roles |
| Duplicate run (step 4) | — | — | yes, disagreements to the checker |
| Extra round (step 8) | — | at most one | at most one |

## 2. Run folder

`<run>` = `~/.cache/ai-kit/research/<YYYY-MM-DD>-<short-slug>/` (absolute path; create it with
`notes/`). It lives outside every repo; the caller files the result where it belongs.

## 3. Perspectives (standard, deep)

Before splitting the question, list 3–6 **perspectives**: who would look at this topic and what
would each ask (a practitioner, a skeptic, a researcher in the field, a newcomer, someone who tried
and failed, the vendor's competitor…). Turn their questions into **aspects** — mutually exclusive,
together covering the question. One researcher per aspect, 2–4 in total; merge the rest.

## 4. Researchers — in parallel, one message

Start every researcher in the same message (Agent tool, `subagent_type: general-purpose`,
`model: sonnet`, in the background). Each brief:

```
Research: <the aspect, phrased as questions>.
Today is <YYYY-MM-DD>. Write "as of <YYYY-MM-DD>" at the top of your notes.
Freshness guidance: <news ≤ 3 days | AI tools and approaches ≤ 1 month | other ≤ 1 year |
any age fits> — prefer the freshest good sources; older ones are fine where they fit.
Own data: <paths / knowledge bases / connectors to search too, or "off — outside sources only">.
<deep only> Subquestions: when a finding opens an important new question inside your aspect,
follow it one level down (at most 2 levels, at most 3 subquestions in total); list them.
Save notes to <run>/notes/<aspect-slug>.md.
First read <skill>/references/researcher.md and follow it.
```

No purpose, no hoped-for answer, no other researchers' findings.

**Deep — duplicate run:** start one more researcher on the **whole question** with a different
search engine: if Exa tools (`mcp__exa__*` or similar) are available, tell it to use them for search
instead of WebSearch; if not, give it the question reworded and say so in the final report
("duplicate run used the same engine"). Notes to `<run>/notes/duplicate.md`.

## 5. Link check — script, no model

```bash
python <skill>/scripts/check_links.py <run>/notes
```

(`python3` on macOS/Linux.) It writes `<run>/links.md`: every URL with its status. Dead links
(4xx/5xx/DNS) — the claims citing only them go to the gaps; tell the checker which ones.

## 6. Compression (standard, deep)

One agent (`general-purpose`, `model: sonnet`) merges all notes:
"First read <skill>/references/compressor.md and follow it. Notes: <run>/notes/. Links:
<run>/links.md. Return the merged findings as your reply." Save its reply, from `# Findings` to the
end, to `<run>/findings.md` as is. Compression drops the process and duplicates — **never a
conclusion, a claim with its source, a contradiction or a gap.** Quick: the single researcher's
notes are the findings (copy them to `findings.md`).

## 7. Checker — fresh, independent

`subagent_type: ai-kit:checker` (if that name is not accepted, `general-purpose` with the same
brief). Model: `sonnet`; `opus` at deep or when the stakes are high. Brief:

```
Check research findings. Today is <YYYY-MM-DD>.
Question: <the question>. Findings: <run>/findings.md. Link status: <run>/links.md.
<deep> Duplicate run: <run>/notes/duplicate.md — compare it with findings.md; every
disagreement is a claim to check.
First read <skill>/references/checker.md and follow it (level: <quick|standard|deep>).
Write your verdicts to <run>/check.md.
```

The checker never gets the researchers' reasoning beyond the files, nor the purpose.

## 8. At most one extra round (standard, deep)

Only if the check leaves a **gap that makes the answer wrong or useless**: start researchers on
just those gaps (same brief form), then link check and checker on the new claims only. Then go to
the writer whatever comes back.

## 9. Writer

One agent (`general-purpose`, `model: sonnet`): "First read <skill>/references/writer.md and follow
it. Question: <…>. Consumer: <human|agent>. Findings: <run>/findings.md. Check: <run>/check.md.
Return the report as your reply<; and write the page <run>/page.html if the consumer is the human
and the result is large>."

Only claims the checker marked **supported** (or partial, marked so) reach the report. Save the
writer's reply, from its first heading to the end, to `<run>/report.md` as is.

## 10. Hand over

- **Human:** a 3–6 line answer in their language, the report path, the depth used, what stayed
  unverified. A large result for the human → the HTML artifact (publish it if the session can).
- **Agent / caller:** the path of `report.md` and the 3–6 line answer. The caller files it (a
  knowledge module by its rules, a task's notes) — this skill knows nothing about where.
- Say plainly when the deep duplicate ran on the same engine, or when the checker could not open
  sources.
