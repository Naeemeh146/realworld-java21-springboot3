# Ruby & PHP Ecosystem Reference

---

## Ruby — Bundler / RubyGems

### Audit

```bash
bundle outdated
bundle audit                        # requires bundler-audit gem
bundle audit update                 # refresh the advisory database
```

### Dependency Tree

```bash
bundle list
gem dependency gem-name --reverse-dependencies
```

### Update Version Declaration

**Gemfile**
```ruby
gem 'package', '~> 2.0'            # was ~> 1.x
gem 'package', '>= 2.0', '< 3.0'
```

**Install after updating declaration**
```bash
bundle update package               # update one gem
bundle install
```

### Compile / Type-check

```bash
bundle exec steep check             # Steep type checker
bundle exec rbs collection install  # RBS types
```

### Run Tests

```bash
bundle exec rspec
bundle exec rspec spec/unit/
bundle exec rspec spec/integration/
bundle exec rspec --format documentation
bundle exec rake test               # Minitest via Rake
```

### Find Affected Code

```bash
grep -r "require 'old_gem'\|require \"old_gem\"" . --include="*.rb"
grep -r "OldClass\|old_method" . --include="*.rb"
```

### Automated Migration Tools

```bash
# rubocop --auto-correct — style and API migration
bundle exec rubocop --auto-correct
bundle exec rubocop -A              # aggressive auto-correct

# rails app:update — Rails built-in upgrade assistant
bin/rails app:update
```

### Transitive Conflict Resolution

```ruby
# Gemfile — override a transitive dependency version
gem 'transitive-gem', '>= 2.0', force: true
```

### Lock File Management

```bash
bundle install --frozen             # CI — fail if Gemfile.lock would change
bundle lock --update package        # update one gem in lockfile
```

### Rollback Restore

```bash
git checkout Gemfile Gemfile.lock ; bundle install
```

---

## PHP — Composer

### Audit

```bash
composer outdated
composer audit                      # security advisories (Composer 2.4+)
```

### Dependency Tree

```bash
composer depends vendor/package     # who depends on it?
composer why vendor/package
```

### Update Version Declaration

**composer.json**
```json
{
  "require": {
    "vendor/package": "^2.0"
  }
}
```

**Install after updating declaration**
```bash
composer require vendor/package:^2.0
composer update vendor/package
```

### Run Tests

```bash
./vendor/bin/phpunit
./vendor/bin/phpunit --testsuite Unit
./vendor/bin/phpunit --testsuite Integration
./vendor/bin/pest                   # Pest testing framework
```

### Find Affected Code

```bash
grep -r "use OldNamespace\\\\" src/ --include="*.php"
grep -r "OldClass\|old_function" src/ --include="*.php"
```

### Automated Migration Tools

```bash
# Rector — rule-based PHP upgrades and migrations
composer require --dev rector/rector
vendor/bin/rector process src --dry-run   # preview
vendor/bin/rector process src             # apply
```

### Transitive Conflict Resolution

```json
{
  "conflict": {
    "vendor/conflicting-package": "<2.0"
  }
}
```

### Lock File Management

```bash
composer install --no-dev --optimize-autoloader   # production
composer install                                   # development
composer update --lock                             # update lock without installing
```

### Rollback Restore

```bash
git checkout composer.json composer.lock ; composer install
```
