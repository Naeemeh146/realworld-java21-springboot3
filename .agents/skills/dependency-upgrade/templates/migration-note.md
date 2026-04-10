# Migration Note: <dependency> <from-version> → <to-version>

## Summary

| Field | Value |
|-------|-------|
| Dependency | `<dependency>` |
| From version | `<from-version>` |
| To version | `<to-version>` |
| Migration path | `<from>` → `<to>` (direct) _or_ `<from>` → `<intermediate>` → `<to>` |
| Date | YYYY-MM-DD |
| Author / agent | |

---

## Breaking Changes

List only the breaking changes that were **relevant to this repository**. Omit changes that did not affect any code here.

| Change | Description |
|--------|-------------|
| Removed API | `OldClass.method()` removed — replaced with `NewClass.method()` |
| Renamed symbol | `oldFunction` → `newFunction` |
| Changed default | `config.option` now defaults to `true` (was `false`) |
| Changed exception | `OldException` replaced by `NewException` |

---

## Files Changed

| File | What changed |
|------|--------------|
| `src/...` | Updated import from `old.pkg` to `new.pkg` |
| `config/...` | Removed deprecated option `old-key` |
| `tests/...` | Updated mock for renamed method |

---

## Patterns Replaced

```
Before:  OldClass.doThing(arg)
After:   NewClass.doThing(arg)
```

```
Before:  import { oldUtil } from 'old-package'
After:   import { newUtil } from 'new-package'
```

_(Add one block per distinct pattern.)_

---

## Validation Performed

- [ ] Compiled / type-checked without errors
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E / smoke tests pass
- [ ] Application starts successfully

Test command used:
```bash
<test-command>
```

---

## Manual Follow-Up Required

- [ ] _Describe any manual step not yet completed_
- [ ] _e.g., update CI pipeline environment variables_
- [ ] _e.g., rotate secrets that the new version requires in a different format_

---

## Unresolved Risks / Assumptions

- _Describe any known risks, unknowns, or assumptions made during the migration_
