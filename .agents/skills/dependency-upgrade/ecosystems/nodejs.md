# Node.js / TypeScript Ecosystem Reference — npm & yarn

## Audit

```bash
# npm
npm outdated
npm audit
npm audit fix                       # auto-fix where safe
npx npm-check-updates               # preview all major bumps
npx npm-check-updates -u            # write bumps to package.json

# yarn (classic)
yarn outdated
yarn audit
yarn upgrade-interactive --latest

# yarn berry (v4)
yarn npm audit
yarn upgrade-interactive
```

## Dependency Tree

```bash
npm ls package-name                 # why is it installed?
npm ls --depth=0                    # top-level only
npm dedupe                          # remove duplicate sub-trees

yarn why package-name
```

## Update Version Declaration

**package.json**
```json
{
  "dependencies": {
    "package": "^2.0.0"
  }
}
```

**Install after updating declaration**
```bash
# npm
npm install package@2.0.0
npm install                         # re-resolve all

# yarn classic
yarn add package@^2.0.0
yarn upgrade package --latest

# yarn berry
yarn add package@^2.0.0
```

## Compile / Type-check

```bash
npx tsc --noEmit                    # TypeScript type check only
npx tsc                             # full compile

# ESLint
npx eslint src/
```

## Run Tests

```bash
# npm
npm test
npm run test:unit
npm run test:integration
npm run test:e2e

# yarn
yarn test
yarn test:unit

# Jest directly
npx jest
npx jest --testPathPattern="integration"
npx jest --watch

# Vitest
npx vitest run
npx vitest run --reporter=verbose
```

## Find Affected Code

```bash
grep -r "require('old-package')\|from 'old-package'" src/ --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx"
grep -r "OldClass\|oldFunction" src/ --include="*.ts" --include="*.tsx"
```

## Automated Migration Tools

```bash
# jscodeshift — AST-based codemods
npx jscodeshift -t <transform-path-or-url> src/
npx jscodeshift -t <transform> --parser=tsx src/    # TSX files
npx jscodeshift -t <transform> --dry src/           # preview only
npx jscodeshift -t <transform> --print src/         # print diffs

# Common transform registries:
# https://github.com/reactjs/react-codemod
# https://github.com/cpojer/js-codemod
```

## Visual / Snapshot Regression

```bash
# Playwright screenshots
npx playwright test --update-snapshots   # record new baseline
npx playwright test                      # compare

# Storybook / Chromatic
npx chromatic --project-token=<token>

# Jest snapshots — update after intentional changes
npx jest --updateSnapshot
```

## E2E Tests

```bash
# Playwright
npx playwright test
npx playwright test tests/smoke/

# Cypress
npx cypress run
npx cypress run --spec "cypress/e2e/smoke*"

# Newman (Postman)
newman run collection.json -e envs/local.json
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

## Lock File Management

```bash
# npm
npm install --package-lock-only     # update lock without installing
npm ci                              # clean install from lock (CI)

# yarn classic
yarn install --frozen-lockfile      # CI — fail if lock would change

# yarn berry
yarn install --immutable            # CI equivalent
```

## Rollback Restore

```bash
git checkout package-lock.json ; npm ci
git checkout yarn.lock ; yarn install --frozen-lockfile
```

## Compatibility Smoke Test (Jest / Vitest)

```js
it("should have compatible peer versions", () => {
  const main = require("main-package/package.json").version;
  const peer = require("peer-package/package.json").version;
  expect(main.startsWith("2.")).toBe(true);
  expect(peer.startsWith("5.")).toBe(true);
});
```
