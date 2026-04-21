# Python Ecosystem Reference — pip / poetry / uv

## Audit

```bash
# pip
pip list --outdated

# uv
uv pip list --outdated

# poetry
poetry outdated
```

## Dependency Tree

```bash
pip show package-name               # shows reverse dependencies
pipdeptree -p package-name          # requires pipdeptree
pipdeptree --reverse -p package-name
```

## Run Tests

```bash
pytest
pytest --tb=short -q                # brief output
```

## Find Affected Code

```bash
grep -r "from old_module import\|import old_module" src/ tests/
grep -r "old_function\|OldClass" src/ tests/
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
