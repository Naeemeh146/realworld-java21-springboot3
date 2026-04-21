# dependency-upgrade skill

Finds code breaking changes caused by a library version upgrade. Given a library name and target version, identifies what will break and where in the codebase.

## Structure

```
dependency-upgrade/
├── SKILL.md                  # analysis steps and output format (load first)
└── refrences/
    ├── jvm.md                # Maven + Gradle
    ├── python.md             # pip / poetry / uv
    ├── nodejs.md             # npm / yarn
    ├── dotnet.md             # NuGet / dotnet CLI
    ├── go.md                 # Go modules
    ├── rust.md               # Cargo
    └── ruby-php.md           # Bundler + Composer
```

## Usage

1. Load `SKILL.md` for the analysis steps and required output format.
2. Load the matching `refrences/<stack>.md` for ecosystem-specific commands (dependency tree, run tests, find affected code).
