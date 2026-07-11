# AGENTS.md

Cross-agent conventions for this repository. Any coding agent (Claude, Codex,
Cursor, opencode, …) working in `nonnest2` — an R package implementing tests of
non-nested models — should read this before making changes.

<!-- BEGIN cwl-agent-guidance -->
## Agent guidance (CWL governance)

### Security & review gate
- Every PR runs a central, required **Security Scan** gate. It combines
  `osv-scan` + `dependency-review` (diff-scoped) with `trivy-fs` (repo-wide,
  CRITICAL/HIGH, fixable only). It runs against each PR base, **including
  stacked PRs**, so a green gate is required before merge.
- A failing **`trivy-fs` is a REAL finding, not a flake.** Read the job log — it
  prints each finding's rule id, severity, and file — or open the run's SARIF
  results. Then **remediate**:
  - This is a pure R package: runtime/suggested dependencies are declared in
    `DESCRIPTION` (`Imports:` / `Suggests:`). Bump the offending package's
    minimum version there if a dependency is flagged.
  - There is currently **no Dockerfile and no k8s manifest** here, so most
    findings will be a committed secret or a config/IaC misconfig — remove and
    rotate the secret, or fix the offending file.
  - For a genuine false positive, add a narrow, documented entry to
    `.trivyignore` (or `.trivyignore.yaml`) — never a blanket ignore.
- Do **not** weaken or disable the gate to make it pass.
- Reproducing locally: a stale DB misses findings. Run
  `trivy --download-db-only` first, then scan the **merge ref** (not just the PR
  head): `trivy fs --severity CRITICAL,HIGH --ignore-unfixed .`.
- The org `code_scanning` ruleset is intentionally **CodeQL-only** (multiple
  code-scanning tools cannot converge on one PR ref). Gating is by the Security
  Scan **job result**, not the `code_scanning` rule — do not add tools to that
  rule.

### Code exploration
- There is **no `.codegraph/` index** in this repo, so use normal search
  (grep/find, `git grep`) to locate and understand R code under `R/`, tests
  under `tests/`, and docs under `man/` and `vignettes/`. If a `.codegraph/`
  index is added later, prefer CodeGraph (`codegraph explore "<query>"`, or the
  code-review-graph MCP tools) before grep/find — it surfaces callers, callees,
  and impact that text search misses.
<!-- END cwl-agent-guidance -->
