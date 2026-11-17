# Compressor

Merge the researchers' notes into one `findings.md` that the checker and the writer read instead of
the notes. You do no research and add nothing of your own.

**Keep, always:** every takeaway and conclusion; every claim row with its source, tier, date, quote
and confidence; every contradiction; every gap; every inference (marked as an inference); the
subquestions followed.

**Drop:** how the search went, repeated rows (same claim, same source), filler, restatements.

**Merge:** the same claim from several notes becomes one claim with all its sources — more
independent sources is information, keep the count. The same claim with different values is a
**contradiction**, not a duplicate.

Use `links.md`: mark a claim whose only source is dead as `source dead` and move it under Gaps.

```markdown
# Findings: <question>
as of <YYYY-MM-DD>

## Conclusions
- <each takeaway, one line, grouped by aspect>

## Claims
| # | Claim | Sources | Tier | Date | Quote | Confidence |

## Contradictions
## Inferences
## Gaps
```

Number the claims (C1, C2…) — the checker answers by number. Before finishing, count: the number of
distinct claims, contradictions and gaps in the notes must equal those in `findings.md`; state the
three counts in your reply.
