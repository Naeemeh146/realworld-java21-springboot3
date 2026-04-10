# JVM Ecosystem Reference — Maven & Gradle

## Audit

```bash
# Maven
mvn versions:display-dependency-updates
mvn versions:display-plugin-updates

# Gradle (requires ben-manes/gradle-versions-plugin)
./gradlew dependencyUpdates
```

## Dependency Tree

```bash
# Maven
mvn dependency:tree -Dincludes=com.example:target-lib

# Gradle
./gradlew :module:dependencies --configuration runtimeClasspath
./gradlew :module:dependencies --configuration compileClasspath
```

## Update Version Declaration

**Maven — pom.xml**
```xml
<dependency>
  <groupId>com.example</groupId>
  <artifactId>target-lib</artifactId>
  <version>2.0.0</version>          <!-- was 1.x -->
</dependency>
```

**Gradle — libs.versions.toml (version catalog)**
```toml
[versions]
target-lib = "2.0.0"    # was 1.x

[libraries]
target-lib = { module = "com.example:target-lib", version.ref = "target-lib" }
```

**Gradle — build.gradle.kts (inline)**
```kotlin
dependencies {
    implementation("com.example:target-lib:2.0.0")
}
```

## Compile

```bash
# Maven
mvn compile -pl affected-module
mvn compile                         # all modules

# Gradle
./gradlew :module:compileJava
./gradlew :module:compileKotlin     # Kotlin
./gradlew classes                   # all modules
```

## Run Tests

```bash
# Maven
mvn test -pl affected-module
mvn verify -pl affected-module      # includes integration tests
mvn test -Dtest=MyTest              # single test class

# Gradle
./gradlew :module:test
./gradlew :module:integrationTest
./gradlew :server:test --tests "*Integration*"
./gradlew test                      # all modules
```

## Find Affected Code

```bash
# Find usages of a renamed class
grep -r "OldClassName" src/ --include="*.java" --include="*.kt"

# Find imports of a changed package
grep -r "import com.example.old" src/ --include="*.java" --include="*.kt"

# Find annotation usage
grep -r "@OldAnnotation" src/ --include="*.java" --include="*.kt"
```

## Automated Migration — OpenRewrite

```bash
# Run a recipe
mvn -U org.openrewrite.maven:rewrite-maven-plugin:run \
  -Drewrite.recipeArtifactCoordinates=org.openrewrite.recipe:rewrite-spring:LATEST \
  -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0

# Dry run (preview only)
mvn -U org.openrewrite.maven:rewrite-maven-plugin:dryRun \
  -Drewrite.recipeArtifactCoordinates=... \
  -Drewrite.activeRecipes=...

# Gradle equivalent
./gradlew rewriteRun
./gradlew rewriteDryRun
```

Common OpenRewrite recipes:
- `org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0`
- `org.openrewrite.java.spring.boot2.UpgradeSpringBoot_2_7`
- `org.openrewrite.java.migrate.Java17` (Java 8/11 → 17)
- `org.openrewrite.java.migrate.Java21`

## Transitive / Peer Conflict Resolution

**Gradle — force a transitive version**
```kotlin
configurations.all {
    resolutionStrategy.force("com.example:conflict-lib:2.0.0")
}
```

**Gradle — substitute a module**
```kotlin
configurations.all {
    resolutionStrategy.dependencySubstitution {
        substitute(module("com.example:old-lib")).using(module("com.example:new-lib:2.0.0"))
    }
}
```

**Maven — exclude a transitive and re-add correct version**
```xml
<dependency>
  <groupId>com.example</groupId>
  <artifactId>parent-lib</artifactId>
  <exclusions>
    <exclusion>
      <groupId>com.example</groupId>
      <artifactId>transitive-lib</artifactId>
    </exclusion>
  </exclusions>
</dependency>
<dependency>
  <groupId>com.example</groupId>
  <artifactId>transitive-lib</artifactId>
  <version>2.0.0</version>
</dependency>
```

**Maven — BOM (Bill of Materials) for aligned versions**
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-dependencies</artifactId>
      <version>3.2.0</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

## Lock File Management

```bash
# Maven — update to latest within constraints
mvn versions:use-latest-releases -Dincludes=com.example:target-lib

# Gradle — write dependency locks
./gradlew dependencies --write-locks
./gradlew resolveAndLockAll --write-locks
```

## Rollback Restore

```bash
git checkout pom.xml                                    # Maven
git checkout libs.versions.toml build.gradle.kts        # Gradle
```

## Compatibility Matrix Examples

| Library | Spring Boot 2.7 | Spring Boot 3.0 | Spring Boot 3.2 |
|---------|----------------|----------------|----------------|
| Spring Framework | 5.3.x | 6.0.x | 6.1.x |
| Spring Security | 5.7.x | 6.0.x | 6.2.x |
| Spring Data | 2022.0.x | 2023.0.x | 2023.1.x |
| Hibernate | 5.6.x | 6.1.x | 6.4.x |
| Java minimum | 8 | 17 | 17 |

## Compatibility Smoke Test (JUnit 5)

```java
@Test
void targetLibVersionIsExpected() {
    String version = TargetLib.class.getPackage().getImplementationVersion();
    assertTrue(version.startsWith("2."), "Expected target-lib ^2, got " + version);
}
```
