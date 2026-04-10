# .NET Ecosystem Reference — NuGet / dotnet CLI

## Audit

```bash
dotnet list package --outdated
```

## Dependency Tree

```bash
dotnet list package --include-transitive
```

## Run Tests

```bash
dotnet test
dotnet test --no-build              # skip rebuild
```

## Find Affected Code

```bash
grep -r "using OldNamespace" . --include="*.cs"
grep -r "OldClass\|OldMethod" . --include="*.cs"
```

## Transitive / Peer Conflict Resolution

**<project>.csproj — override transitive version**
```xml
<PackageReference Include="TransitivePackage" Version="2.0.0" />
```

**Directory.Packages.props — central override**
```xml
<PackageVersion Include="TransitivePackage" Version="2.0.0" OverriddenVersion="true" />
```

## Compatibility Matrix Example

| Package | .NET 6 | .NET 8 | .NET 9 |
|---------|--------|--------|--------|
| ASP.NET Core | 6.x | 8.x | 9.x |
| Entity Framework Core | 6.x | 8.x | 9.x |
| System.Text.Json | 6.x | 8.x | 9.x |
