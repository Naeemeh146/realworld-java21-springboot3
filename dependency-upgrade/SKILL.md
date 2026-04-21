---
name: dependency-upgrade
description: >
  Identify and fix code breaking changes caused by a library or dependency version upgrade.
  Use this skill whenever: a user asks "what will break if I upgrade X to version Y?",
  a PR bumps a dependency and needs impact assessment, there are compilation errors or test
  failures after a library update, a user wants to resolve dependency conflicts or migrate to
  a new major version, or the user mentions terms like "breaking changes", "bump dependency",
  "upgrade library", "migrate to new version", "incompatible API", or "after upgrading X stopped working".
  Also trigger when a user shows a build error or stack trace that resembles a changed or removed API.
compatibility: Intended for coding agents working in any language ecosystem with access to source code, tests, lockfiles, and manifests.
metadata:
  owner: opentext-debricked
  domain: sca
  version: "1.1"
---

# Breaking Change Finder

You are a breaking change specialist. Given a **library name**, **current version**, and **target version**, your job is to identify every breaking change the upgrade introduces, locate all affected usages in the repository, and apply the necessary code changes to make the codebase compatible with the new version.

## Companion files
Load the relevant file for your target ecosystem before starting:

| Ecosystem | Reference |
|-----------|-----------|
| JVM (Maven / Gradle) | [refrences/jvm.md](refrences/jvm.md) |
| Python (pip / poetry / uv) | [refrences/python.md](refrences/python.md) |
| Node.js / TypeScript (npm / yarn) | [refrences/nodejs.md](refrences/nodejs.md) |
| .NET / NuGet | [refrences/dotnet.md](refrences/dotnet.md) |
| Go | [refrences/go.md](refrences/go.md) |
| Rust / Cargo | [refrences/rust.md](refrences/rust.md) |
| Ruby / PHP | [refrences/ruby-php.md](refrences/ruby-php.md) |

---

## When to Use This Skill

- A user asks "what will break if I upgrade X from version A to B?"
- A dependency version bump has been proposed and the impact needs to be assessed
- Compilation failures or test failures appeared after a version bump
- Resolving dependency conflicts or incompatible version ranges

## Core Objective

Given a **dependency name**, **current version**, and **target version**:

1. Research all breaking changes introduced between the two versions
2. Locate every affected usage in the repository
3. Apply the necessary code changes to restore compatibility
4. Verify the fix by running the test suite

**Tests must never be removed.** When a test breaks because of the upgrade, find the replacement API or behavior and update the test to use it. Removing a test would hide real regressions — every test that existed before the upgrade must still exist (and pass) after it.

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

## Step 1 — Confirm the Dependency

1. Confirm the exact package name and current version from the manifest/lockfile → see references file
2. Inspect the dependency tree to identify all transitive consumers of this library → see references file
3. Run the full test suite on the **current** version to establish a passing baseline → see references file
4. If the upgrade crosses multiple major versions, list each intermediate step

## Step 2 — Research Breaking Changes

Use these sources in priority order:
1. Official migration guide for the target version
2. Official changelog / release notes
3. Package registry documentation
4. GitHub releases, pull requests, issues, source diffs

Collect for each version step:
- Removed or renamed APIs / symbols
- Deprecated APIs that became hard removals (check deprecation warnings in the baseline test run output — they often predict the exact failures in the target version)
- Changed defaults, config formats, or bootstrap patterns
- Changed peer or transitive requirements
- Changed type signatures, return values, or exception behavior
- Changed annotation / decorator / middleware contracts

**Compatibility matrix** — when the library has peer dependencies, build this table:

| Peer package | current version compat | target version compat |
|--------------|------------------------|-----------------------|
| `peer-lib-a` | `^3.0`                 | `^4.0`                |
| `peer-lib-b` | `^1.2`                 | `^2.0`                |

## Step 3 — Find Affected Code

For each breaking change identified in Step 2, search the repository for every affected usage.

Search for:
- Import / require / using statements for the changed package
- Direct API calls, adapter or wrapper classes
- Configuration files (YAML, TOML, XML, `.properties`, `.env`)
- Annotations, decorators, middleware, plugins, providers
- Tests mocking or asserting dependency behavior
- CLI commands or scripts referencing the dependency
- Lockfiles and manifest version constraints

Use workspace search tools (`grep_search`, `semantic_search`) to locate all call sites.

For multi-major upgrades, repeat Steps 2–3 for each intermediate version in order.

## Step 3a — Identify Unused Imports After API Changes

For each file touched in Step 3, flag any import of a removed or replaced symbol that has no remaining references after migration. Mark it `Remove unused import` in the output table. Never remove automatically — offer the removal and let the user confirm.

---

## Step 4 — Apply Fixes

Bump the dependency version in the manifest/lockfile first, then apply every change from the Step 3 table:

- Replace removed/renamed API call sites with the new equivalents
- Update configuration keys, annotation contracts, and bootstrap patterns
- Update tests to assert the new API behavior — remember, tests must be updated, never removed
- Remove unused imports identified in Step 3a (only after confirming with the user)
- If the upgrade is multi-major, apply and verify one major version at a time

Document each change with a brief inline comment only when the replacement is non-obvious (e.g., the old and new APIs have different semantics). Don't add comments for mechanical renames.

## Step 5 — Verify

Run the full test suite on the upgraded version → see references file.

- **All tests green**: the migration is complete. Report the final count of changed files.
- **New failures**: diagnose each one — determine whether it is caused by a missed breaking change (go back to Step 2) or a pre-existing issue unrelated to this upgrade. Fix upgrade-caused failures; report pre-existing ones without touching them.
- **Tests cannot run** (missing environment, CI-only, etc.): apply the code changes as far as possible, then note which tests could not be verified and why.

---

## Required Output

### Breaking change table (produced after Step 3, before applying fixes)

| # | Breaking change | Affected files | What must change | Source |
|---|-----------------|----------------|-----------------|--------|
| 1 | `OldClass` removed | `src/Foo.java:12`, `src/Bar.java:34` | Replace with `NewClass` from `com.example.new` | https://github.com/example/lib/releases/tag/v2.0.0 |
| 2 | Config key `old.key` renamed | `application.yml:8` | Rename to `new.key` | https://example.com/docs/migration/v2 |
| 3 | `OldClass` import now unused | `src/Foo.java:1` | Remove unused import (offered, not automatic) | — |

### Migration summary (produced after Step 5)

- Total breaking changes found and fixed
- Total files modified
- Peer/transitive dependencies that also needed version updates
- Breaking changes for which no affected usage was found (safe to ignore)
- Any test failures that are pre-existing and unrelated to this upgrade
- Any tests that could not be verified (environment gaps)
