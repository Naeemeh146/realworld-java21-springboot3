# Python Ecosystem Reference — pip / poetry / uv

## Audit

```bash
# pip
pip list --outdated
pip-audit                           # requires pip-audit

# uv
uv pip list --outdated

# poetry
poetry outdated
poetry audit                        # requires poetry-audit-plugin
```

## Dependency Tree

```bash
pip show package-name               # shows reverse dependencies
pipdeptree -p package-name          # requires pipdeptree
pipdeptree --reverse -p package-name
```

## Update Version Declaration

**requirements.txt**
```text
package==2.0.0                      # exact
package>=2.0.0,<3.0.0               # range
```

**pyproject.toml (poetry)**
```toml
[tool.poetry.dependencies]
package = "^2.0"                    # was ^1.x
```

**pyproject.toml (PEP 621 / uv)**
```toml
[project]
dependencies = [
    "package>=2.0.0,<3.0.0",
]
```

**Install after updating declaration**
```bash
# pip
pip install "package==2.0.0"
pip freeze > requirements.txt

# pip-compile (pip-tools)
pip-compile --upgrade-package package requirements.in
pip-sync requirements.txt

# poetry
poetry add "package@^2.0"
poetry update package

# uv
uv add "package>=2.0.0,<3.0.0"
uv sync
```

## Compile / Type-check

```bash
mypy src/
mypy src/ --strict                  # stricter
pyright src/                        # alternative
```

## Run Tests

```bash
pytest
pytest tests/unit/
pytest tests/integration/
pytest -m integration               # run by marker
pytest -k "test_something"          # run by keyword
pytest --tb=short -q                # brief output
```

## Find Affected Code

```bash
grep -r "from old_module import\|import old_module" src/ tests/
grep -r "old_function\|OldClass" src/ tests/
```

## Automated Migration Tools

```bash
# pyupgrade — modernize syntax for a target Python version
pyupgrade --py310-plus **/*.py
pyupgrade --py311-plus **/*.py

# django-upgrade — Django-specific API migrations
django-upgrade --target-version 4.2 **/*.py
django-upgrade --target-version 5.0 **/*.py

# libCST codemods — custom AST-based transforms
python -m libcst.tool codemod transforms.RenameImport .
python -m libcst.tool list          # list available codemods
```

## Custom Migration Script

```python
# migrate_api.py
import re
from pathlib import Path

patterns = [
    (r'from old\.module import OldClass', 'from new.module import NewClass'),
    (r'\bold_function\b', 'new_function'),
]

for source_file in Path('src').rglob('*.py'):
    text = source_file.read_text(encoding='utf-8')
    changed = False
    for old, new in patterns:
        updated = re.sub(old, new, text)
        if updated != text:
            text = updated
            changed = True
    if changed:
        source_file.write_text(text, encoding='utf-8')
        print(f"Updated {source_file}")
```

## Transitive / Peer Conflict Resolution

```bash
# pip — pin the transitive in constraints.txt
echo "transitive-package==2.0.0" >> constraints.txt
pip install -r requirements.txt -c constraints.txt

# poetry — add with constraint
poetry add "transitive-package@2.0.0"

# uv — override
uv add "transitive-package==2.0.0"
```

## Lock File Management

```bash
# pip-tools
pip-compile requirements.in         # regenerate requirements.txt
pip-compile --upgrade requirements.in
pip-sync requirements.txt           # install exactly what's in lock

# poetry
poetry lock                         # regenerate poetry.lock
poetry install --sync               # install from lock

# uv
uv lock                             # regenerate uv.lock
uv sync                             # install from lock
```

## Rollback Restore

```bash
git checkout requirements.txt ; pip install -r requirements.txt
git checkout poetry.lock ; poetry install
git checkout uv.lock ; uv sync
```

## Compatibility Smoke Test (pytest)

```python
import importlib.metadata
import pytest

def test_compatible_versions():
    main = importlib.metadata.version("main-package")
    peer = importlib.metadata.version("peer-package")
    assert main.startswith("2."), f"Expected main-package ^2, got {main}"
    assert peer.startswith("5."), f"Expected peer-package ^5, got {peer}"
```
