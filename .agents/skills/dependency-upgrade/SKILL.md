---
name: dependency-upgrade
description: Manage major dependency version upgrades with compatibility analysis, staged rollout, and comprehensive testing. Use when upgrading framework versions, updating major dependencies, or managing breaking changes in libraries across any language ecosystem.
compatibility: Intended for coding agents working in any language ecosystem (JVM, Python, Node.js, .NET, Go, Ruby, Rust, PHP) with access to source code, tests, lockfiles/manifests, changelogs, and migration guides.
metadata:
  owner: opentext-debricked
  domain: sca
  version: "1.0"
---

# Dependency Upgrade

You are a dependency upgrade specialist operating across any language ecosystem.

Your job is to plan, execute, and validate major dependency version upgrades while minimizing risk and preserving existing behavior.

## When to Use This Skill

- Upgrading major framework or runtime versions
- Updating security-vulnerable dependencies
- Modernizing legacy or end-of-life dependencies
- Resolving dependency conflicts or incompatible version ranges
- Planning incremental upgrade paths across multiple major versions
- Testing compatibility matrices between interdependent packages
- Automating or standardizing dependency update workflows

## Core Objective

Given:
- dependency name
- current version
- target version

You must:
1. Identify the actual breaking changes between the current and target versions
2. Locate all directly and indirectly affected usages in the repository
3. Plan a safe, incremental upgrade path
4. Execute the upgrade in stages with validation at each step
5. Summarize exactly what changed, why, and what follow-up is required

## Non-Negotiable Rules

- Only change code required by the dependency upgrade
- Do not refactor, reformat, rename, or clean up unrelated code
- Do not remove tests unless they are truly obsolete because the target version removed the feature
- Prefer replacing broken usage with target-version-compatible usage rather than deleting behavior
- Preserve existing behavior unless the upgraded dependency requires a behavior change
- If the upgrade crosses multiple major versions, apply migrations in version order

---

## Semantic Versioning Review

```
MAJOR.MINOR.PATCH (e.g., 2.3.1)

MAJOR: Breaking changes
MINOR: New features, backward compatible
PATCH: Bug fixes, backward compatible
```

Version range notation (varies by ecosystem):

| Ecosystem | Exact   | Patch only   | Minor+Patch         |
|-----------|---------|--------------|---------------------|
| npm/yarn  | `2.3.1` | `~2.3.1`     | `^2.3.1`            |
| Maven     | `2.3.1` | `[2.3.1]`    | `[2.3,3.0)`         |
| Gradle    | `2.3.1` | `2.3.+`      | `2.+`               |
| pip       | `==2.3.1`| `~=2.3.1`   | `>=2.3.1,<3.0`      |
| NuGet     | `2.3.1` | `[2.3.1,2.4)`| `[2.3.1,3.0)`       |
| Go        | `v2.3.1`| N/A (explicit)| N/A (explicit)     |
| Cargo     | `2.3.1` | `~2.3.1`     | `^2.3.1`            |
| Bundler   | `2.3.1` | `~> 2.3.1`   | `~> 2.3`            |

---

## Phase 1 — Audit and Plan

### Identify Outdated Dependencies

**JVM (Maven)**
```bash
mvn versions:display-dependency-updates
mvn versions:display-plugin-updates
```

**JVM (Gradle)**
```bash
./gradlew dependencyUpdates          # requires ben-manes/gradle-versions-plugin
./gradlew dependencies               # show full dependency tree
```

**Python (pip / pip-audit)**
```bash
pip list --outdated
pip-audit
uv pip list --outdated               # if using uv
```

**Python (poetry)**
```bash
poetry outdated
poetry audit                         # requires poetry-audit-plugin
```

**Node.js (npm)**
```bash
npm outdated
npm audit
npm audit fix
npx npm-check-updates                # preview major bumps
```

**Node.js (yarn)**
```bash
yarn outdated
yarn audit
yarn upgrade-interactive --latest    # interactive picker
```

**.NET (NuGet)**
```bash
dotnet list package --outdated
dotnet list package --vulnerable
```

**Go**
```bash
go list -u -m all                    # list upgradeable modules
govulncheck ./...                    # security audit
```

**Rust (Cargo)**
```bash
cargo outdated
cargo audit
```

**Ruby (Bundler)**
```bash
bundle outdated
bundle audit
```

**PHP (Composer)**
```bash
composer outdated
composer audit
```

### Analyze Dependency Trees

**JVM**
```bash
mvn dependency:tree -Dincludes=com.example:target-lib
./gradlew :module:dependencies --configuration runtimeClasspath
```

**Python**
```bash
pip show package-name               # show dependents
pipdeptree -p package-name
```

**Node.js**
```bash
npm ls package-name                 # why is it installed?
npm dedupe                          # deduplicate
```

**Go**
```bash
go mod why module/path
go mod graph | grep module/path
```

---

## Phase 2 — Research Breaking Changes

Use these sources in priority order:
1. Official migration guides for the target version
2. Official changelogs and release notes
3. Package registry documentation
4. Upstream GitHub releases, pull requests, issues, and source diffs
5. Repository code, tests, lockfiles, manifests, and CI configs

Collect for each version step:
- Removed APIs or symbols
- Renamed APIs or symbols
- Deprecated APIs that became errors or hard removals
- Changed defaults or configuration formats
- Changed initialization or bootstrap patterns
- Changed runtime behavior or assumptions
- Changed peer or transitive requirements
- Changed error or exception behavior
- Changed type signatures or return values
- Changed annotation/decorator/middleware contracts

### Compatibility Matrix Pattern

Maintain a compatibility table when upgrading a package with peer dependencies:

| Package              | v14.x compat | v16.x compat | v18.x compat |
|----------------------|--------------|--------------|--------------|
| `peer-lib-a`         | `^3.0`       | `^4.0`       | `^5.0`       |
| `peer-lib-b`         | `^1.2`       | `^1.2`       | `^2.0`       |
| `test-helper`        | `^8.0`       | `^9.0`       | `^10.0`      |

Adapt format to your ecosystem. Examples:

- **Spring Boot**: Spring Framework version × Spring Security version × Spring Data version
- **Django**: Django version × DRF version × Celery version
- **React**: React version × React DOM × React Router × testing-library
- **.NET**: runtime version × ASP.NET Core × Entity Framework Core

---

## Phase 3 — Staged Upgrade Execution

### Upgrade one dependency at a time. Never upgrade everything simultaneously.

**Step 1 — Create a working branch**
```bash
git checkout -b upgrade/<dependency>-<from>-to-<to>
```

**Step 2 — Update the version declaration**

*Maven (pom.xml)*
```xml
<!-- Before -->
<dependency>
  <groupId>com.example</groupId>
  <artifactId>target-lib</artifactId>
  <version>1.2.3</version>
</dependency>

<!-- After -->
<dependency>
  <groupId>com.example</groupId>
  <artifactId>target-lib</artifactId>
  <version>2.0.0</version>
</dependency>
```

*Gradle (libs.versions.toml)*
```toml
[versions]
target-lib = "2.0.0"    # was 1.2.3
```

*pip*
```bash
pip install "package==2.0.0"
pip freeze > requirements.txt
# or with poetry:
poetry add "package@^2.0"
```

*npm*
```bash
npm install package@2.0.0
```

*.NET*
```bash
dotnet add package PackageName --version 2.0.0
```

*Go*
```bash
go get module/path@v2.0.0
go mod tidy
```

*Cargo*
```toml
[dependencies]
package = "2.0"
```

**Step 3 — Compile or type-check**

Static failures surface most API breakage before any test runs.

```bash
# JVM
mvn compile -pl affected-module
./gradlew :module:compileJava

# Python
mypy src/

# TypeScript
npx tsc --noEmit

# .NET
dotnet build

# Go
go build ./...

# Rust
cargo check
```

**Step 4 — Run tests**

Run in order: unit → integration → e2e. Stop at first failure and fix before proceeding.

```bash
# JVM (Maven)
mvn test -pl affected-module
mvn verify -pl affected-module   # includes integration tests

# JVM (Gradle)
./gradlew :module:test
./gradlew :module:integrationTest

# Python
pytest tests/unit/
pytest tests/integration/

# Node.js
npm test
npm run test:e2e

# .NET
dotnet test

# Go
go test ./...

# Rust
cargo test

# Ruby
bundle exec rspec
```

**Step 5 — Fix each failure, iterate, then validate again**

Only fix upgrade-related failures. Do not weaken tests or delete assertions. Do not fix unrelated pre-existing failures.

---

## Phase 4 — Handling Breaking Changes

### Finding Affected Code

Search for:
- Import statements for the changed package
- Direct API calls
- Adapter or wrapper classes around the dependency
- Configuration files (YAML, TOML, XML, .properties, .env)
- Annotations, decorators, middleware, plugins, providers
- Tests mocking or asserting dependency behavior
- CLI commands or scripts referencing the dependency
- Lockfiles and manifest version constraints

**JVM example — find all usages of a renamed class**
```bash
grep -r "OldClassName" src/ --include="*.java" --include="*.kt"
```

**Python example — find all imports of changed module**
```bash
grep -r "from old_module import\|import old_module" src/ tests/
```

**Node.js example**
```bash
grep -r "require('old-package')\|from 'old-package'" src/ --include="*.ts" --include="*.js"
```

### Automated Migration Tools by Ecosystem

**JVM**
```bash
# OpenRewrite — recipe-based automated refactoring
mvn -U org.openrewrite.maven:rewrite-maven-plugin:run \
  -Drewrite.recipeArtifactCoordinates=... \
  -Drewrite.activeRecipes=...

# Example: migrate Spring Boot 2 to 3
mvn -U org.openrewrite.maven:rewrite-maven-plugin:run \
  -Drewrite.recipeArtifactCoordinates=org.openrewrite.recipe:rewrite-spring:LATEST \
  -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0
```

**Python**
```bash
# pyupgrade — modernize Python syntax
pyupgrade --py310-plus **/*.py

# django-upgrade — automated Django migration fixes
django-upgrade --target-version 4.2 **/*.py

# libCST codemods — custom migration transforms
python -m libcst.tool codemod transforms.RenameImport .
```

**Node.js / TypeScript**
```bash
# jscodeshift — AST-based codemods
npx jscodeshift -t <transform> <path>
npx jscodeshift -t <transform> --parser=tsx src/   # for TSX

# Dry run to preview
npx jscodeshift -t <transform> --dry src/
```

**.NET**
```bash
# upgrade-assistant — official Microsoft upgrade tool
dotnet tool install -g upgrade-assistant
upgrade-assistant upgrade <project.csproj>

# Try Convert — project file modernization
dotnet tool install --global try-convert
try-convert
```

**Go**
```bash
# gopls fix — apply suggested fixes
gopls fix -a ./...

# Gorename — rename symbols
gorename -from "pkg.OldName" -to NewName
```

**Rust**
```bash
# cargo fix — automated lint fixes
cargo fix --edition
cargo fix --allow-dirty
```

### Custom Migration Script Pattern

When automated tools are unavailable, write a targeted migration script:

```python
# migrate_api.py — example: rename a moved symbol across all source files
import re
from pathlib import Path

patterns = [
    # (old_pattern, new_replacement)
    (r'from old\.module import OldClass', 'from new.module import NewClass'),
    (r'old_function\(', 'new_function('),
]

for source_file in Path('src').rglob('*.py'):
    text = source_file.read_text()
    for old, new in patterns:
        text = re.sub(old, new, text)
    source_file.write_text(text)
```

Adapt to `sed`, `awk`, PowerShell, or any scripting language available in the environment.

---

## Phase 5 — Testing Strategy

### Compatibility Validation Test

Write a smoke-test that confirms peer versions match expectations:

**Python (pytest)**
```python
import importlib.metadata
import pytest

def test_compatible_versions():
    main = importlib.metadata.version("main-package")
    peer = importlib.metadata.version("peer-package")
    assert main.startswith("2."), f"Expected main-package ^2, got {main}"
    assert peer.startswith("5."), f"Expected peer-package ^5, got {peer}"
```

**JVM (JUnit 5)**
```java
@Test
void targetLibVersionIsExpected() {
    String version = TargetLib.class.getPackage().getImplementationVersion();
    assertTrue(version.startsWith("2."), "Expected target-lib ^2, got " + version);
}
```

**Node.js (Jest/Vitest)**
```js
it("should have compatible peer versions", () => {
  const main = require("main-package/package.json").version;
  const peer = require("peer-package/package.json").version;
  expect(main.startsWith("2.")).toBe(true);
  expect(peer.startsWith("5.")).toBe(true);
});
```

### Integration Tests

Run the smallest meaningful integration scenario that exercises the upgraded dependency:

```bash
# JVM: run only tests tagged for the relevant slice
./gradlew :server:test --tests "*Integration*"

# Python: run integration marker
pytest -m integration

# Node.js
npm run test:integration

# .NET
dotnet test --filter Category=Integration
```

### Snapshot / Visual Regression

When upgrading UI libraries, capture and compare before/after snapshots:

```bash
# Storybook visual testing
npx chromatic --project-token=...

# Playwright screenshot comparison
npx playwright test --update-snapshots   # record new baseline
npx playwright test                      # compare against baseline
```

### End-to-End Smoke Tests

Run the minimal E2E path that touches the upgraded library:

```bash
# Playwright
npx playwright test tests/smoke/

# Cypress
npx cypress run --spec "cypress/e2e/smoke*"

# Newman (Postman collection)
newman run api-docs/Conduit.postman_collection.json -e envs/local.json
```

---

## Phase 6 — Automated Dependency Update Configuration

### Renovate

```json
{
  "extends": ["config:base"],
  "packageRules": [
    {
      "matchUpdateTypes": ["minor", "patch"],
      "automerge": true
    },
    {
      "matchUpdateTypes": ["major"],
      "automerge": false,
      "labels": ["major-update"],
      "reviewers": ["team-leads"]
    }
  ],
  "schedule": ["before 3am on Monday"],
  "timezone": "America/New_York"
}
```


## Phase 7 — Rollback Plan

Before starting any upgrade, snapshot the current state on a branch. Always upgrade on a separate branch, never directly on the main branch.

```bash
#!/usr/bin/env bash
# upgrade-with-rollback.sh

PACKAGE=$1
TARGET_VERSION=$2
BRANCH="upgrade/${PACKAGE}-${TARGET_VERSION}"

# Save working state
git checkout -b "$BRANCH"

# Attempt upgrade (adapt command to your ecosystem)
# npm:    npm install "${PACKAGE}@${TARGET_VERSION}"
# pip:    pip install "${PACKAGE}==${TARGET_VERSION}"
# gradle: edit libs.versions.toml
# mvn:    edit pom.xml
# go:     go get "${PACKAGE}@v${TARGET_VERSION}"

# Validate
if <build-and-test-command>; then
  echo "Upgrade successful"
  git add -A
  git commit -m "chore: upgrade ${PACKAGE} to ${TARGET_VERSION}"
else
  echo "Upgrade failed — rolling back"
  git checkout -
  git branch -D "$BRANCH"
  echo "Restored previous state"
  exit 1
fi
```

### Ecosystem-specific restore commands

| Ecosystem | Restore command                              |
|-----------|----------------------------------------------|
| npm       | `git checkout package-lock.json ; npm ci`    |
| yarn      | `git checkout yarn.lock ; yarn install --frozen-lockfile` |
| pip       | `git checkout requirements.txt ; pip install -r requirements.txt` |
| poetry    | `git checkout poetry.lock ; poetry install`  |
| Maven     | `git checkout pom.xml`                       |
| Gradle    | `git checkout libs.versions.toml build.gradle.kts` |
| NuGet     | `git checkout *.csproj ; dotnet restore`     |
| Go        | `git checkout go.mod go.sum ; go mod download` |
| Cargo     | `git checkout Cargo.lock ; cargo fetch`      |
| Bundler   | `git checkout Gemfile.lock ; bundle install` |

---

## Common Upgrade Patterns

### Lock File Management

Keep lockfiles committed to version control. After upgrading, update them:

```bash
# npm — update only target package in lockfile
npm install package@latest --package-lock-only
npm ci                              # clean install from lock

# yarn
yarn upgrade package --latest
yarn install --frozen-lockfile      # CI

# pip
pip-compile --upgrade-package package requirements.in
pip-sync requirements.txt

# Maven — update lockfile equivalent (BOM / dependency management)
mvn versions:use-latest-releases -Dincludes=com.example:target-lib

# Gradle
./gradlew dependencies --write-locks   # if using dependency locking

# Go
go mod tidy

# Cargo
cargo update -p package
```

### Peer and Transitive Dependency Resolution

When a direct upgrade forces peer or transitive version changes:

```bash
# npm — inspect and resolve peer conflicts
npm install --legacy-peer-deps       # bypass strict peer check (last resort)
npm install --force                  # override (avoid in production)

# Gradle — force a version for a transitive dep
configurations.all {
    resolutionStrategy.force("com.example:conflict-lib:2.0.0")
}

# Maven — exclude a transitive and re-add correct version
<dependency>
  <groupId>com.example</groupId>
  <artifactId>parent-lib</artifactId>
  <exclusions>
    <exclusion>
      <groupId>com.example</groupId>
      <artifactId>transitive-lib</artifactId>
    </exclusion>
  </exclusions>
</dependency>

# pip — pin the transitive in constraints.txt
echo "transitive-package==2.0.0" >> constraints.txt
pip install -r requirements.txt -c constraints.txt

# Go — replace a transitive dep
go mod edit -replace old/module=new/module@v2.0.0

# Cargo — override a dependency
[patch.crates-io]
conflict-crate = { path = "../patched-version" }
```

### Multi-Major Version Migrations

When upgrading across more than one major version:

1. Identify all intermediate major versions (e.g., 1 → 2 → 3 → 4)
2. Apply one major version migration at a time
3. Validate (compile + test) after each major step before proceeding
4. Commit a separate snapshot after each successful step

This avoids conflating multiple sets of breaking changes, which makes debugging failures much easier.

---

## Required Final Output

At the end of any upgrade engagement, provide:

1. What breaking changes were relevant to this repository
2. What files were changed and why
3. What API patterns were replaced (old → new)
4. What validation was run and what passed or failed
5. Whether the app or service builds and tests pass on the target version
6. Any manual follow-up still required (including unresolved risks or assumptions)

If there are actual breaking changes, also create:

`docs/migrations/<dependency>-<from>-to-<to>.md`

Include: dependency name, version range, migration path, breaking-change summary, files updated, patterns replaced, validation performed, manual follow-up required, unresolved risks.
