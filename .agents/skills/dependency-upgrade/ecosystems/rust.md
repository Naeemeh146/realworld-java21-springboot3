# Rust Ecosystem Reference — Cargo

## Audit

```bash
cargo outdated                      # requires cargo-outdated
cargo audit                         # requires cargo-audit
cargo deny check                    # requires cargo-deny (advisories + licenses)
```

## Dependency Tree

```bash
cargo tree
cargo tree -i package-name          # inverted — who depends on it?
cargo tree -d                       # show duplicate versions
```

## Update Version Declaration

**Cargo.toml**
```toml
[dependencies]
package = "2.0"                     # was "1.x"

# With features
package = { version = "2.0", features = ["feature-a"] }
```

**Update via CLI**
```bash
cargo update -p package             # update to latest compatible
cargo add package@2.0               # requires cargo-edit
```

## Compile / Type-check

```bash
cargo check                         # fast type check, no binary
cargo build
cargo build --release
cargo clippy                        # lints
```

## Run Tests

```bash
cargo test
cargo test test_name                # single test
cargo test -- --nocapture           # show println output
cargo test --features feature-a
cargo nextest run                   # requires cargo-nextest (faster)
```

## Find Affected Code

```bash
grep -r "use old_crate::" src/ --include="*.rs"
grep -r "old_crate::" src/ --include="*.rs"
```

## Automated Migration Tools

```bash
# cargo fix — apply compiler-suggested fixes
cargo fix
cargo fix --edition                 # migrate to new Rust edition
cargo fix --allow-dirty             # allow uncommitted changes

# cargo clippy --fix — apply clippy suggestions
cargo clippy --fix
```

## Edition Migrations

```bash
# Step 1: update Cargo.toml
# edition = "2021"   was "2018"

# Step 2: run automated fix
cargo fix --edition

# Step 3: verify
cargo build
cargo test
```

## Transitive / Peer Conflict Resolution

```toml
# Cargo.toml — patch a transitive dep with a local or fork version
[patch.crates-io]
conflict-crate = { path = "../patched-version" }
conflict-crate = { git = "https://github.com/fork/crate", branch = "fix" }
```

## Lock File Management

`Cargo.lock` — commit for binaries/applications, `.gitignore` for libraries.

```bash
cargo update                        # update Cargo.lock to latest compatible
cargo update -p package             # update one crate only
```

## Rollback Restore

```bash
git checkout Cargo.toml Cargo.lock ; cargo fetch
```
