# Ruby & PHP Ecosystem Reference

---

## Ruby — Bundler / RubyGems

### Audit

```bash
bundle outdated
```

### Dependency Tree

```bash
bundle list
gem dependency gem-name --reverse-dependencies
```

### Run Tests

```bash
bundle exec rspec
bundle exec rake test               # Minitest via Rake
```

### Find Affected Code

```bash
grep -r "require 'old_gem'\|require \"old_gem\"" . --include="*.rb"
grep -r "OldClass\|old_method" . --include="*.rb"
```

### Transitive Conflict Resolution

```ruby
# Gemfile — override a transitive dependency version
gem 'transitive-gem', '>= 2.0', force: true
```

---

## PHP — Composer

### Audit

```bash
composer outdated
```

### Dependency Tree

```bash
composer depends vendor/package     # who depends on it?
composer why vendor/package
```

### Run Tests

```bash
./vendor/bin/phpunit
./vendor/bin/pest                   # Pest testing framework
```

### Find Affected Code

```bash
grep -r "use OldNamespace\\\\" src/ --include="*.php"
grep -r "OldClass\|old_function" src/ --include="*.php"
```

### Transitive Conflict Resolution

```json
{
  "conflict": {
    "vendor/conflicting-package": "<2.0"
  }
}
```
