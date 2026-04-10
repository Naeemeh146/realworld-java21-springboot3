# .NET Ecosystem Reference — NuGet / dotnet CLI

## Audit

```bash
dotnet list package --outdated
dotnet list package --vulnerable
dotnet list package --include-transitive --vulnerable
```

## Dependency Tree

```bash
dotnet list package --include-transitive
```

## Update Version Declaration

**<project>.csproj**
```xml
<PackageReference Include="PackageName" Version="2.0.0" />
```

**Install / update via CLI**
```bash
dotnet add package PackageName --version 2.0.0
dotnet restore
```

**Central Package Management — Directory.Packages.props**
```xml
<PackageVersion Include="PackageName" Version="2.0.0" />
```

## Compile / Type-check

```bash
dotnet build
dotnet build --no-restore           # skip restore if already done
dotnet build -c Release             # release configuration
```

## Run Tests

```bash
dotnet test
dotnet test --filter Category=Unit
dotnet test --filter Category=Integration
dotnet test --logger trx            # output TRX report
dotnet test --no-build              # skip rebuild
```

## Find Affected Code

```bash
grep -r "using OldNamespace" . --include="*.cs"
grep -r "OldClass\|OldMethod" . --include="*.cs"
```

## Automated Migration Tools

```bash
# upgrade-assistant — official Microsoft tool
dotnet tool install -g upgrade-assistant
upgrade-assistant upgrade <project.csproj>
upgrade-assistant analyze <project.csproj>

# try-convert — modernize project file format
dotnet tool install --global try-convert
try-convert

# Roslyn analyzers built into the SDK surface migration warnings at build time
dotnet build /warnaserror           # treat migration warnings as errors
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

## Lock File Management

```bash
dotnet restore --locked-mode        # CI — fail if lock would change
dotnet restore --force-evaluate     # force re-resolve
```

Enable lock files in the project file:
```xml
<PropertyGroup>
  <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
</PropertyGroup>
```

## Rollback Restore

```bash
git checkout *.csproj Directory.Packages.props ; dotnet restore
```

## Compatibility Matrix Example

| Package | .NET 6 | .NET 8 | .NET 9 |
|---------|--------|--------|--------|
| ASP.NET Core | 6.x | 8.x | 9.x |
| Entity Framework Core | 6.x | 8.x | 9.x |
| System.Text.Json | 6.x | 8.x | 9.x |
