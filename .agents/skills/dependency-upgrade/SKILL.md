---
name: dependency-upgrade
description: Manage major dependency version upgrades with compatibility analysis, staged rollout, and comprehensive testing. Use when upgrading framework versions, updating major dependencies, or managing breaking changes in libraries across any language ecosystem.
compatibility: Intended for coding agents working in any language ecosystem with access to source code, tests, lockfiles/manifests, changelogs, and migration guides.
metadata:
  owner: opentext-debricked
  domain: sca
  version: "1.1"
---

# Dependency Upgrade

You are a dependency upgrade specialist operating across any language ecosystem.

Your job is to plan, execute, and validate major dependency version upgrades while minimizing risk and preserving existing behavior.

## Companion files

Load the relevant file for your target ecosystem before starting:

| Ecosystem | Reference |
|-----------|-----------|
| JVM (Maven / Gradle) | [ecosystems/jvm.md](ecosystems/jvm.md) |
| Python (pip / poetry / uv) | [ecosystems/python.md](ecosystems/python.md) |
| Node.js / TypeScript (npm / yarn) | [ecosystems/nodejs.md](ecosystems/nodejs.md) |
| .NET / NuGet | [ecosystems/dotnet.md](ecosystems/dotnet.md) |
| Go | [ecosystems/go.md](ecosystems/go.md) |
| Rust / Cargo | [ecosystems/rust.md](ecosystems/rust.md) |
| Ruby / PHP | [ecosystems/ruby-php.md](ecosystems/ruby-php.md) |

Copy-ready config templates:

| Template | Use for |
|----------|---------|
| [templates/renovate.json](templates/renovate.json) | Automated PR-based updates |
| [templates/rollback.sh](templates/rollback.sh) | Safe upgrade-and-rollback shell script |
| [templates/migration-note.md](templates/migration-note.md) | Post-upgrade migration note |

---

## When to Use This Skill

- Upgrading major framework or runtime versions
- Updating security-vulnerable dependencies
- Resolving dependency conflicts or incompatible version ranges
- Planning incremental upgrade paths across multiple major versions
- Automating or standardizing dependency update workflows

## Core Objective

Given a **dependency name**, **current version**, and **target version**, you must:

1. Identify actual breaking changes between the versions
2. Locate all affected usages in the repository
3. Plan a safe, incremental upgrade path
4. Execute in stages with validation at each step
5. Summarize what changed, why, and what follow-up is required

## Non-Negotiable Rules

- Only change code required by the dependency upgrade
- Do not refactor, reformat, rename, or clean up unrelated code
- Do not remove tests unless they are truly obsolete because the target version removed the feature
- Prefer replacing broken usage with target-version-compatible usage rather than deleting behavior
- Preserve existing behavior unless the upgraded dependency requires a behavior change
- If the upgrade crosses multiple major versions, apply migrations in version order

---

## Semantic Versioning Quick Reference

```
MAJOR.MINOR.PATCH  →  MAJOR = breaking, MINOR = additive, PATCH = fix
```

| Ecosystem | Exact    | Patch only     | Minor+Patch         |
|-----------|----------|----------------|---------------------|
| npm/yarn  | `2.3.1`  | `~2.3.1`       | `^2.3.1`            |
| Maven     | `2.3.1`  | `[2.3.1]`      | `[2.3,3.0)`         |
| Gradle    | `2.3.1`  | `2.3.+`        | `2.+`               |
| pip       | `==2.3.1`| `~=2.3.1`      | `>=2.3.1,<3.0`      |
| NuGet     | `2.3.1`  | `[2.3.1,2.4)`  | `[2.3.1,3.0)`       |
| Go        | `v2.3.1` | explicit only  | explicit only       |
| Cargo     | `2.3.1`  | `~2.3.1`       | `^2.3.1`            |
| Bundler   | `2.3.1`  | `~> 2.3.1`     | `~> 2.3`            |

---

## Phase 1 — Audit and Plan

1. Determine current and target versions (confirm exact package name)
2. Run the **outdated** and **audit** commands for your ecosystem → see ecosystem file
3. Inspect the dependency tree to find all transitive consumers → see ecosystem file
4. If the upgrade crosses multiple major versions, list each intermediate step now

## Phase 2 — Research Breaking Changes

Use these sources in priority order:
1. Official migration guide for the target version
2. Official changelog / release notes
3. Package registry documentation
4. GitHub releases, pull requests, issues, source diffs
5. Repository code, tests, lockfiles, manifests, CI configs

Collect for each version step:
- Removed or renamed APIs / symbols
- Deprecated APIs that became errors or hard removals
- Changed defaults, config formats, or bootstrap patterns
- Changed peer or transitive requirements
- Changed type signatures, return values, or exception behavior
- Changed annotation / decorator / middleware contracts

**Compatibility matrix** — when upgrading a package with peer dependencies, build a table before touching code:

| Peer package | current major compat | target major compat |
|--------------|----------------------|---------------------|
| `peer-lib-a` | `^3.0`               | `^4.0`              |
| `peer-lib-b` | `^1.2`               | `^2.0`              |

## Phase 3 — Staged Upgrade Execution

**Never upgrade everything simultaneously. One dependency at a time.**

**Step 1 — Branch**
```bash
git checkout -b upgrade/<dependency>-<from>-to-<to>
```

**Step 2 — Update the version declaration** → see ecosystem file for exact syntax

**Step 3 — Compile / type-check** (surfaces API breakage before tests run) → see ecosystem file

**Step 4 — Run tests: unit → integration → e2e** (stop and fix at first failure) → see ecosystem file

**Step 5 — Iterate on failures** — only fix upgrade-related breakage; do not weaken assertions or fix pre-existing failures

## Phase 4 — Handling Breaking Changes

### Find affected code

Search for:
- Import / require / using statements for the changed package
- Direct API calls, adapter or wrapper classes
- Configuration files (YAML, TOML, XML, `.properties`, `.env`)
- Annotations, decorators, middleware, plugins, providers
- Tests mocking or asserting dependency behavior
- CLI commands or scripts referencing the dependency
- Lockfiles and manifest version constraints

Use workspace search tools (`grep_search`, `semantic_search`) to locate all call sites before making changes.

### Automated migration tools

Each ecosystem has dedicated codemod / migration tooling → see ecosystem file.

When no tool is available, write a targeted script that applies find-and-replace patterns across source files, then delete the script after use.

## Phase 5 — Testing Strategy

Run in this order, stopping at first failure:

| Level | Goal |
|-------|------|
| Compatibility smoke test | Confirm installed versions match expected ranges |
| Unit tests | Verify isolated behavior unchanged |
| Integration tests | Verify the upgraded dependency works end-to-end in context |
| Visual / snapshot regression | For UI library upgrades only |
| E2E / API smoke tests | Verify the running application still behaves correctly |

Ecosystem-specific test commands → see ecosystem file.

## Phase 6 — Automated Update Configuration

For ongoing automated updates, copy and adapt:
- [templates/renovate.json](templates/renovate.json) — Renovate (multi-ecosystem, flexible automerge rules)

## Phase 7 — Rollback Plan

Always work on a branch (Step 1 above). If validation fails, restore cleanly:

```bash
git checkout -          # return to previous branch
git branch -D upgrade/… # delete failed branch
```

Then restore the lockfile from git and reinstall. Ecosystem-specific restore commands → see ecosystem file.

For a reusable script that wraps upgrade + test + rollback, copy [templates/rollback.sh](templates/rollback.sh).

### Multi-major version migrations

1. List every intermediate major version (e.g., 1 → 2 → 3 → 4)
2. Apply one major migration at a time
3. Validate (compile + test) after each step before proceeding
4. Commit a snapshot after each successful step

---

## Required Final Output

At the end of any upgrade, provide:

1. What breaking changes were relevant to this repository
2. What files were changed and why
3. What API patterns were replaced (old → new)
4. What validation was run and what passed or failed
5. Whether the app, build, and tests pass on the target version
6. Any manual follow-up still required

If there are actual breaking changes, also create a migration note by copying [templates/migration-note.md](templates/migration-note.md) to:

`docs/migrations/<dependency>-<from>-to-<to>.md`
