# Go Ecosystem Reference

## Audit

```bash
go list -u -m all                   # list upgradeable modules
govulncheck ./...                   # security audit (requires govulncheck)
```

## Dependency Tree

```bash
go mod why module/path
go mod graph | grep module/path
go mod graph | grep direct          # direct deps only
```

## Update Version Declaration

**go.mod**
```
require (
    module/path v2.0.0
)
```

**Update via CLI**
```bash
go get module/path@v2.0.0
go mod tidy                         # remove unused, add missing
```

**Upgrade to latest patch**
```bash
go get module/path@latest
go get -u ./...                     # upgrade all direct deps to latest minor/patch
go mod tidy
```

## Major Version Modules

Go major versions ≥ v2 require a module path suffix:

```bash
# v1 → v2: import path changes
go get module/path/v2@v2.0.0

# Update all import paths in source
find . -name "*.go" -exec sed -i 's|module/path"|module/path/v2"|g' {} +
```

## Compile

```bash
go build ./...
go vet ./...                        # static analysis
```

## Run Tests

```bash
go test ./...
go test ./... -run TestName
go test ./... -race                 # data race detector
go test -v ./pkg/...                # verbose
go test -count=1 ./...              # disable test caching
```

## Find Affected Code

```bash
grep -r "\"old/module/path\"" . --include="*.go"
grep -r "old\.Symbol\|old\.Function" . --include="*.go"
```

## Automated Migration Tools

```bash
# gopls fix — apply suggested quick-fixes
gopls fix -a ./...

# gorename — rename symbols (requires tools)
gorename -from "package.OldName" -to NewName

# gofmt — reformat after changes
gofmt -w ./...
```

## Transitive / Peer Conflict Resolution

```bash
# Replace a dependency (e.g., fork or patched version)
go mod edit -replace old/module=new/module@v2.0.0
go mod tidy

# Pin to a specific pseudo-version
go get module/path@v0.0.0-20240101000000-abcdefabcdef

# Remove the replace directive after fix is upstream
go mod edit -dropreplace old/module
```

## Lock File Management

`go.sum` is the lock file — always commit it.

```bash
go mod tidy                         # regenerate go.sum
go mod verify                       # verify checksums
```

## Rollback Restore

```bash
git checkout go.mod go.sum ; go mod download
```
