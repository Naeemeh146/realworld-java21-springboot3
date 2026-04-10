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

## Run Tests

```bash
# Maven
mvn test
mvn test -pl affected-module        # single module

# Gradle
./gradlew test                      # all modules
./gradlew :module:test              # single module
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

## Compatibility Matrix Examples

| Library | Spring Boot 2.7 | Spring Boot 3.0 | Spring Boot 3.2 |
|---------|----------------|----------------|----------------|
| Spring Framework | 5.3.x | 6.0.x | 6.1.x |
| Spring Security | 5.7.x | 6.0.x | 6.2.x |
| Spring Data | 2022.0.x | 2023.0.x | 2023.1.x |
| Hibernate | 5.6.x | 6.1.x | 6.4.x |
| Java minimum | 8 | 17 | 17 |
