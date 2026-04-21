# Node.js / TypeScript Ecosystem Reference — npm & yarn

## Audit

```bash
# npm
npm outdated
npx npm-check-updates               # preview all major bumps
npx npm-check-updates -u            # write bumps to package.json

# yarn (classic)
yarn outdated
yarn upgrade-interactive --latest

# yarn berry (v4)
yarn upgrade-interactive
```

## Dependency Tree

```bash
npm ls package-name                 # why is it installed?
npm ls --depth=0                    # top-level only
npm dedupe                          # remove duplicate sub-trees

yarn why package-name
```

## Run Tests

```bash
# npm
npm test

# yarn
yarn test

# Jest directly
npx jest

# Vitest
npx vitest run
```

## Find Affected Code

```bash
grep -r "require('old-package')\|from 'old-package'" src/ --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx"
grep -r "OldClass\|oldFunction" src/ --include="*.ts" --include="*.tsx"
```

## Transitive / Peer Conflict Resolution

```bash
# npm 7+ strict peer deps
npm install --legacy-peer-deps       # bypass (last resort)
npm install --force                  # override (avoid in production)

# npm overrides (package.json)
{
  "overrides": {
    "transitive-package": "2.0.0"
  }
}

# yarn resolutions (package.json)
{
  "resolutions": {
    "transitive-package": "^2.0.0"
  }
}
```
