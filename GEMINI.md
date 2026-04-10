# Gemini Agent Instructions

## Dependency Upgrade Skill

When asked to upgrade a dependency, update a library version, or handle breaking changes from a library update, load and follow the instructions in:

```
.agents/skills/dependency-upgrade/SKILL.md
```

Then load the relevant ecosystem file from `.agents/skills/dependency-upgrade/ecosystems/` based on the target language/build tool (jvm.md, python.md, nodejs.md, dotnet.md, go.md, rust.md, ruby-php.md).

Use the templates in `.agents/skills/dependency-upgrade/templates/` as needed.
