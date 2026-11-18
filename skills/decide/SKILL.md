---
name: decide
description: Choose among solutions that already exist — a pattern, a rule, an approach, a tool, a design — and say why. Frames the question and the criteria with the human. Collects the options: the place's own way, what similar products and fields do (through ai-kit:research), and the human's own proposal as a candidate from the start. Checks the claims an option stands on. Weighs each option's pros against its cons with weights and a one-line balance, and combines parts into a hybrid when it beats each part. A fresh critic attacks the top options, and the chosen option is walked through step by step. Returns a recommendation with every option, what is found practice and what is our own rule, open questions with defaults, and what was dropped. Calls ai-kit:brainstorm only when every collected option is weak. Use for "which approach", "which pattern", "choose between", "what should we use", "weigh the options", "pros and cons of…".
---

# decide — pick the best of what exists, with reasons

You are the **coordinator**, in the **main session** — never inside a subagent (subagents cannot
start agents). Every step of thinking is a **background agent**; the main session stays free for
the human. You start agents, save text they return, check cheap facts and talk to the human. You
never collect, weigh, attack or write the result yourself, and no agent sees another's reasoning —
only its files.

Use this skill when suitable solutions **already exist** (in the place, in similar products, in the
human's head) and the job is to choose the one that suits us best. When nothing suitable exists and
something fundamentally new must be invented, use `<kit>/skills/brainstorm`.

`<skill>` is this skill's base directory; `<kit>` = `<skill>/../..` (the kit's root, where `docs/`
and `skills/` live); `<research>` = `<kit>/skills/research`; `<journey>` = `<kit>/skills/journey`.
`<run>` is the folder for this decision: the one the caller names (a task's notes), else
`~/.cache/ai-kit/decide/<YYYY-MM-DD>-<short-slug>/` (absolute path). Shared terms and the rule
"Think it through before the human sees it": [contract](../../docs/contract.md).

## Files — who writes what

Claude Code refuses a subagent's Write of a markdown file whose name starts with `report`,
`summary`, `findings` or `analysis`; that is the harness's rule, not a bug to get around. Agents
here write working files with allowed names (`brief.md`, `own.md`, `options.md`, `weigh.md`,
`attack.md`, `result.md`); research runs by its own skill. If any write is refused, the agent
returns the full text and you save it verbatim — never by renaming, Bash or a script.

## 1. Frame — the question, the criteria

From the request, the task file and the place's code and docs, write `<run>/brief.md` (a short
agent may draft it; you check it):

- **The question** in one sentence, and what is already fixed (decisions, laws, contracts, the
  place's rules — final, not weighed).
- **Who is affected** — each role that lives with the answer (users, developers, whoever
  maintains it), in their conditions.
- **The criteria** — what makes an option good *here*, each with a weight (high · medium · low),
  from the request; add the usual ones when they apply (fit with what exists, cost of changing
  what exists, effort and risk, how people really use it, how easy it is to maintain, what the
  evidence supports). Cost is a criterion, not a veto.
- **The human's own proposal**, if the request has one, worded as they said it, labelled theirs.

Anything vague, contradictory or doubtful in the request — ask (AskUserQuestion, a batch, each
with a default), do not guess. A question the caller already answered is not asked again. If
the human is present, show the brief in 10 lines and let them correct it before anything runs.

## 2. Collect the options — three sources, in parallel, in the background

One message, all agents in the background.

1. **The place's own way** — an agent that changes no file but `own.md` (`model: sonnet`) reads the place's code and docs
   for the question: what is done now and where, the places that do it differently, the rules and
   decisions that bear on it. Notes: `<run>/own.md`, each claim with `path:line`.
2. **What similar products and fields do** — run `<research>` (read its `SKILL.md`, follow it;
   you stay its coordinator). Depth `standard`; `deep` for a large decision. Give it **neutral
   questions** (how do similar products solve X, what does it cost them, what went wrong), never
   our options or the hoped-for answer. Tell it the three checks to apply:
   **relevance** (does the source's case look like ours — same kind of users, scale, conditions),
   **contradiction** (where sources disagree, name both sides and which is right for which case),
   **balance** (for every approach, evidence for and against, not only its promoters). Findings:
   `<run>/research.md`.
3. **The human's proposal**, if there is one, enters as a candidate — it needs no source.

Then one agent (`general-purpose`, `model: opus`, high effort) writes `<run>/options.md` from the
three: each distinct option with what it is in a few lines, **where it comes from** — *found
practice* (who does it, source), *our own rule* (the place's code or decision), *the human's
proposal* — and what it would change here. Parts that can be combined are marked; duplicates
merge. Do not drop an option for being unfashionable.

## 3. Check what an option stands on

When the research or the agents mark a claim as an **inference** (not seen in a source) and an
option would stand or fall on it, have it checked in the place's own code or docs before weighing:
a cheap read you may do yourself, or a quick agent. Add the result to `options.md` (checked by
reading `path:line` / checked by running / still an inference).

## 4. Weigh

One agent (`general-purpose`, `model: opus`, high effort — the human of this kit asked for high
effort on thinking roles) weighs. Its brief: "First read `<skill>/references/weigh.md`. Brief: `<run>/brief.md`.
Options: `<run>/options.md`. Own: `<run>/own.md`. Research: `<run>/research.md`. Write
`<run>/weigh.md`." For every option it writes **pros against cons**, each with a weight from
the brief's criteria and one line of why. It adds a one-line balance ("pros: 2 high, 1 medium ·
cons: 1 high → keeps") and the cost of getting there. An option is dropped only when its cons
outweigh its pros or it breaks something fixed.

**Hybrids:** when parts of different options combine into something that beats
each part, write it as its own option ("assembled from …") and weigh it the same way. The human's
proposal is weighed like the others, and the file says honestly where it wins and where it loses.

**All options weak?** If no option keeps a favourable balance, say so to the human in a line and
run `<kit>/skills/brainstorm` (you coordinate it; mode: without me, depth: standard; its brief:
this question, the criteria, why each existing option fails, `<run>/brief.md` as the caller's
brief and `<run>` as its run folder) to invent new ones, then weigh them together with the old. Only then, and
once.

## 5. Attack

A fresh critic (`ai-kit:checker`, `model: opus`; never the weigher): "First read
`<skill>/references/attack.md`. Brief: `<run>/brief.md`. Weighing: `<run>/weigh.md`. Research:
`<run>/research.md`. Write `<run>/attack.md`." It attacks the top options as the **skeptic** and as
**each affected user** from the brief. Continue the weigher (it remembers) to answer each attack
once — fix the weighing or concede in one line — and re-state the balance. An option whose fatal
attack stands is dropped with the reason. If the human is present, show them: the options left,
the strongest attack on each, the answer.

## 6. Walk the chosen option through

For the recommended option (and the runner-up when the balance is close), a fresh implementer
follows `<journey>/SKILL.md` (its brief names `<run>` as the folder) and writes
`<run>/journeys.md`: the concrete case step by step — what
the person sees, does and gets, in each state, for each role. A fresh checker then checks it with
`<kit>/skills/task/references/check-journey.md` (contract, "Think it through"); the implementer
fixes, the same checker re-checks, to "satisfied" (loop cap: 3 rounds, per the contract). A gap that comes back changes the option or
drops it; re-weigh when it does. With no person-facing steps (a rule, an internal pattern), the
walkthrough is one concrete case through the code or process, step by step.

## 7. Result

An agent writes `<run>/result.md`, in the human's language, from the files and without adding
options:

- **Recommendation** — the option (or hybrid) in a few lines, why it wins on the criteria, what it
  costs, what it leaves worse.
- **Every option** — pros, cons, cost, balance, in a table; the human's proposal marked, with
  where it wins and loses.
- **What is found practice and what is our own rule** — per option, so the human sees what is
  borrowed with a source and what is a choice of this place.
- **The walkthrough** of the recommended option.
- **The strongest attack** on it and the answer.
- **Open questions** — each with options and a **default** you would take.
- **Graveyard** — options dropped, one line each with the balance or attack that dropped them.
- **What stayed unverified.**

Hand over: 3–6 lines in the human's language, the path of `result.md`, what stayed unverified. A
large result for the human is also an HTML page (cards per option, the evidence folded under
each). In a task, the caller records the pick in the task's decisions; the human decides — this
skill recommends.
