---
external help file: d365fo.tools-help.xml
Module Name: d365fo.tools
online version:
schema: 2.0.0
---

# Get-D365AssemblyBinding

## SYNOPSIS
Get assembly bindings from an AOS configuration file

## SYNTAX

```
Get-D365AssemblyBinding [[-Path] <String>] [[-AssemblyName] <String[]>] [[-AssemblyPath] <String>]
 [[-TemplatePath] <String>] [-OnlyAssemblyMismatch] [-OnlyTemplateMismatch] [<CommonParameters>]
```

## DESCRIPTION
Read assembly identities and binding redirects from the runtime section of a configuration file.
Compare redirects with DLL assembly metadata from the detected AOS bin folder by default.
Optionally compare redirects with a package web.config template.
This command does not modify configuration files or load the inspected DLLs into PowerShell.

Returns ConfigurationPath, AssemblyName, PublicKeyToken, Culture, ProcessorArchitecture,
AppliesTo, OldVersion, NewVersion, AssemblyFile, AssemblyVersion, AssemblyStatus,
TemplateOldVersion, TemplateNewVersion and TemplateStatus.
Bindings without a redirect have empty version properties.

AssemblyStatus is NotChecked, MissingAssembly, UnreadableAssembly, IdentityMismatch,
VersionMismatch or Match.
TemplateStatus is NotChecked, MissingBinding, AmbiguousBinding,
RedirectMismatch or Match.

## EXAMPLES

### EXAMPLE 1
```
Get-D365AssemblyBinding
```

List assembly bindings in the detected AOS web.config and compare them with the deployed DLLs.

### EXAMPLE 2
```
Get-D365AssemblyBinding -Path "C:\AOSService\webroot\web.config" -AssemblyName System.Memory,System.Text.Json -AssemblyPath "C:\AOSService\webroot\bin"
```

Compare the two selected redirects with the identities and versions of the deployed DLLs.

### EXAMPLE 3
```
Get-D365AssemblyBinding -Path "C:\AOSService\webroot\web.config" -AssemblyName "Microsoft.IdentityModel.*" -TemplatePath "C:\Temp\Package\web.config"
```

Compare IdentityModel binding redirects with a package template.

### EXAMPLE 4
```
Get-D365AssemblyBinding -OnlyAssemblyMismatch
```

List only bindings that do not match the deployed AOS DLLs.

### EXAMPLE 5
```
Get-D365AssemblyBinding -TemplatePath "C:\Temp\Package\web.config" -OnlyTemplateMismatch
```

List only bindings that do not match the package template, regardless of DLL comparison status.

## PARAMETERS

### -Path
Path to the configuration file to inspect.
Defaults to the web.config file in the detected AOS web root.
Only inline assembly bindings are inspected.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(Join-Path -Path $Script:AOSPath -ChildPath $Script:WebConfig)
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssemblyName
One or more assembly names to include.
Wildcards are supported.
Defaults to all assemblies.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @("*")
Accept pipeline input: False
Accept wildcard characters: True
```

### -AssemblyPath
Directory containing the deployed DLLs.
Defaults to the bin folder under the detected AOS web root, independently of Path.
Specify an empty string to skip DLL comparison.
Looks for AssemblyName.dll directly in this directory, without searching subdirectories.
Compares the assembly identity and AssemblyVersion, not FileVersion or ProductVersion.
A matching version does not guarantee binary compatibility.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $(Join-Path -Path $Script:AOSPath -ChildPath "bin")
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplatePath
Optional path to a package configuration template.
Compares redirects with template bindings having the same identity and appliesTo value.
A template can itself contain stale redirects; it is not treated as an authoritative fix.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlyAssemblyMismatch
Only return bindings whose AssemblyStatus is not Match.
Includes missing or unreadable DLLs, identity or version mismatches, and NotChecked results.
TemplateStatus does not affect this filter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlyTemplateMismatch
Only return bindings whose TemplateStatus is not Match.
Includes missing or ambiguous template bindings, redirect mismatches, and NotChecked results.
Without TemplatePath, all results have TemplateStatus NotChecked and remain visible.
When both mismatch switches are supplied, both filters must be satisfied.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject
## NOTES
Tags: Configuration, Assembly, BindingRedirect, WebConfig, Authentication, OData

## RELATED LINKS

[Backup-D365WebConfig]()

[Restore-D365WebConfig]()

