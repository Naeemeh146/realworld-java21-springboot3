# dependency-upgrade skill

Plans, executes, and validates major dependency upgrades across any language ecosystem.

## Structure

```
dependency-upgrade/
├── SKILL.md                  # workflow phases and decision rules (load first)
├── ecosystems/
│   ├── jvm.md                # Maven + Gradle
│   ├── python.md             # pip / poetry / uv
│   ├── nodejs.md             # npm / yarn
│   ├── dotnet.md             # NuGet / dotnet CLI
│   ├── go.md                 # Go modules
│   ├── rust.md               # Cargo
│   └── ruby-php.md           # Bundler + Composer
└── templates/
    ├── renovate.json         # Renovate config
    ├── rollback.sh           # upgrade + rollback script
    └── migration-note.md     # migration doc template
```

## Usage

1. Load `SKILL.md` for the workflow.
2. Load the matching `ecosystems/<stack>.md` for commands specific to the project's language.
3. Copy files from `templates/` directly into the target repository as needed.
