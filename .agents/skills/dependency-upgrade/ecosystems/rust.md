# Rust Ecosystem Reference — Cargo

## Audit

```bash
cargo outdated                      # requires cargo-outdated
```

## Dependency Tree

```bash
cargo tree
cargo tree -i package-name          # inverted — who depends on it?
cargo tree -d                       # show duplicate versions
```

## Run Tests

```bash
cargo test
```

## Find Affected Code

```bash
grep -r "use old_crate::" src/ --include="*.rs"
grep -r "old_crate::" src/ --include="*.rs"
```

## Transitive / Peer Conflict Resolution

```toml
# Cargo.toml — patch a transitive dep with a local or fork version
[patch.crates-io]
conflict-crate = { path = "../patched-version" }
conflict-crate = { git = "https://github.com/fork/crate", branch = "fix" }
```
