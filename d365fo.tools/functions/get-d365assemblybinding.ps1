
<#
    .SYNOPSIS
        Get assembly bindings from an AOS configuration file
        
    .DESCRIPTION
        Read assembly identities and binding redirects from the runtime section of a configuration file.
        Compare redirects with DLL assembly metadata from the detected AOS bin folder by default.
        Optionally compare redirects with a package web.config template.
        This command does not modify configuration files or load the inspected DLLs into PowerShell.
        
        Returns ConfigurationPath, AssemblyName, PublicKeyToken, Culture, ProcessorArchitecture,
        AppliesTo, OldVersion, NewVersion, AssemblyFile, AssemblyVersion, AssemblyStatus,
        TemplateOldVersion, TemplateNewVersion and TemplateStatus.
        Bindings without a redirect have empty version properties.
        
        AssemblyStatus is NotChecked, MissingAssembly, UnreadableAssembly, IdentityMismatch,
        VersionMismatch or Match. TemplateStatus is NotChecked, MissingBinding, AmbiguousBinding,
        RedirectMismatch or Match.
        
    .PARAMETER Path
        Path to the configuration file to inspect.
        Defaults to the web.config file in the detected AOS web root.
        Only inline assembly bindings are inspected.
        
    .PARAMETER AssemblyName
        One or more assembly names to include. Wildcards are supported.
        Defaults to all assemblies.
        
    .PARAMETER AssemblyPath
        Directory containing the deployed DLLs.
        Defaults to the bin folder under the detected AOS web root, independently of Path.
        Specify an empty string to skip DLL comparison.
        Looks for AssemblyName.dll directly in this directory, without searching subdirectories.
        Compares the assembly identity and AssemblyVersion, not FileVersion or ProductVersion.
        A matching version does not guarantee binary compatibility.
        
    .PARAMETER TemplatePath
        Optional path to a package configuration template.
        Compares redirects with template bindings having the same identity and appliesTo value.
        A template can itself contain stale redirects; it is not treated as an authoritative fix.
        
    .PARAMETER OnlyAssemblyMismatch
        Only return bindings whose AssemblyStatus is not Match.
        Includes missing or unreadable DLLs, identity or version mismatches, and NotChecked results.
        TemplateStatus does not affect this filter.
        
    .PARAMETER OnlyTemplateMismatch
        Only return bindings whose TemplateStatus is not Match.
        Includes missing or ambiguous template bindings, redirect mismatches, and NotChecked results.
        Without TemplatePath, all results have TemplateStatus NotChecked and remain visible.
        When both mismatch switches are supplied, both filters must be satisfied.
        
    .EXAMPLE
        PS C:\> Get-D365AssemblyBinding
        
        List assembly bindings in the detected AOS web.config and compare them with the deployed DLLs.
        
    .EXAMPLE
        PS C:\> Get-D365AssemblyBinding -Path "C:\AOSService\webroot\web.config" -AssemblyName System.Memory,System.Text.Json -AssemblyPath "C:\AOSService\webroot\bin"
        
        Compare the two selected redirects with the identities and versions of the deployed DLLs.
        
    .EXAMPLE
        PS C:\> Get-D365AssemblyBinding -Path "C:\AOSService\webroot\web.config" -AssemblyName "Microsoft.IdentityModel.*" -TemplatePath "C:\Temp\Package\web.config"
        
        Compare IdentityModel binding redirects with a package template.
        
    .EXAMPLE
        PS C:\> Get-D365AssemblyBinding -OnlyAssemblyMismatch
        
        List only bindings that do not match the deployed AOS DLLs.
        
    .EXAMPLE
        PS C:\> Get-D365AssemblyBinding -TemplatePath "C:\Temp\Package\web.config" -OnlyTemplateMismatch
        
        List only bindings that do not match the package template, regardless of DLL comparison status.
        
    .OUTPUTS
        System.Management.Automation.PSCustomObject
        
    .NOTES
        Tags: Configuration, Assembly, BindingRedirect, WebConfig, Authentication, OData
        
    .LINK
        Backup-D365WebConfig
        
    .LINK
        Restore-D365WebConfig
#>
function Get-D365AssemblyBinding {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [string] $Path = $(Join-Path -Path $Script:AOSPath -ChildPath $Script:WebConfig),

        [SupportsWildcards()]
        [string[]] $AssemblyName = @("*"),

        [string] $AssemblyPath = $(Join-Path -Path $Script:AOSPath -ChildPath "bin"),

        [string] $TemplatePath,

        [switch] $OnlyAssemblyMismatch,

        [switch] $OnlyTemplateMismatch
    )

    if (-not (Test-PathExists -Path $Path -Type Leaf)) { return }
    if ($AssemblyPath -and -not (Test-PathExists -Path $AssemblyPath -Type Container)) { return }
    if ($TemplatePath -and -not (Test-PathExists -Path $TemplatePath -Type Leaf)) { return }
    if (Test-PSFFunctionInterrupt) { return }

    try {
        $configurationPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
        $configuration = New-Object System.Xml.XmlDocument
        $configuration.XmlResolver = $null
        $configuration.Load($configurationPath)
        $namespace = New-Object System.Xml.XmlNamespaceManager($configuration.NameTable)
        $namespace.AddNamespace("assembly", "urn:schemas-microsoft-com:asm.v1")
        $bindingXPath = "/configuration/runtime/assembly:assemblyBinding/assembly:dependentAssembly"
        $bindings = $configuration.SelectNodes($bindingXPath, $namespace)

        $templateBindings = @()
        if ($TemplatePath) {
            $template = New-Object System.Xml.XmlDocument
            $template.XmlResolver = $null
            $template.Load((Resolve-Path -LiteralPath $TemplatePath -ErrorAction Stop).ProviderPath)
            $templateNamespace = New-Object System.Xml.XmlNamespaceManager($template.NameTable)
            $templateNamespace.AddNamespace("assembly", "urn:schemas-microsoft-com:asm.v1")
            $templateBindings = @($template.SelectNodes($bindingXPath, $templateNamespace))
        }
    }
    catch {
        Stop-PSFFunction -Message "Unable to read assembly bindings from the configuration file or template." -ErrorRecord $_
        return
    }

    foreach ($binding in $bindings) {
        $identity = $binding.SelectSingleNode("assembly:assemblyIdentity", $namespace)
        if (-not $identity) { continue }
        $name = $identity.GetAttribute("name")
        $included = $false
        foreach ($pattern in $AssemblyName) {
            if ($name -like $pattern) { $included = $true; break }
        }
        if (-not $included) { continue }

        $redirect = $binding.SelectSingleNode("assembly:bindingRedirect", $namespace)
        $oldVersion = ""
        $newVersion = ""
        if ($redirect) {
            $oldVersion = $redirect.GetAttribute("oldVersion")
            $newVersion = $redirect.GetAttribute("newVersion")
        }
        $publicKeyToken = $identity.GetAttribute("publicKeyToken")
        $culture = $identity.GetAttribute("culture")
        $processorArchitecture = $identity.GetAttribute("processorArchitecture")
        $appliesTo = $binding.ParentNode.GetAttribute("appliesTo")
        $assemblyFile = $null
        $assemblyVersion = $null
        $assemblyStatus = "NotChecked"

        if ($AssemblyPath) {
            $assemblyFile = Join-Path -Path $AssemblyPath -ChildPath "$name.dll"
            if (-not (Test-Path -LiteralPath $assemblyFile -PathType Leaf)) {
                $assemblyStatus = "MissingAssembly"
            }
            else {
                try {
                    $assemblyFile = (Resolve-Path -LiteralPath $assemblyFile -ErrorAction Stop).ProviderPath
                    $assembly = [System.Reflection.AssemblyName]::GetAssemblyName($assemblyFile)
                    $assemblyVersion = $assembly.Version.ToString()
                    $assemblyToken = ([System.BitConverter]::ToString($assembly.GetPublicKeyToken())).Replace("-", "")
                    $assemblyCulture = $assembly.CultureName
                    if (-not $assemblyCulture) { $assemblyCulture = "neutral" }
                    $expectedCulture = $culture
                    if (-not $expectedCulture) { $expectedCulture = "neutral" }
                    if ($assembly.Name -ne $name -or $assemblyToken -ne $publicKeyToken -or
                        $assemblyCulture -ne $expectedCulture -or
                        ($processorArchitecture -and $assembly.ProcessorArchitecture.ToString() -ne $processorArchitecture)) {
                        $assemblyStatus = "IdentityMismatch"
                    }
                    elseif ($assemblyVersion -ne $newVersion) {
                        $assemblyStatus = "VersionMismatch"
                    }
                    else {
                        $assemblyStatus = "Match"
                    }
                }
                catch {
                    $assemblyStatus = "UnreadableAssembly"
                    Write-PSFMessage -Level Verbose -Message "Unable to inspect assembly metadata for $assemblyFile." -ErrorRecord $_
                }
            }
        }

        if ($OnlyAssemblyMismatch -and $assemblyStatus -eq "Match") { continue }

        $templateOldVersion = $null
        $templateNewVersion = $null
        $templateStatus = "NotChecked"
        if ($TemplatePath) {
            $matchingBindings = @($templateBindings | Where-Object {
                $templateIdentity = $_.SelectSingleNode("assembly:assemblyIdentity", $templateNamespace)
                $templateIdentity -and $templateIdentity.GetAttribute("name") -eq $name -and
                $templateIdentity.GetAttribute("publicKeyToken") -eq $publicKeyToken -and
                $templateIdentity.GetAttribute("culture") -eq $culture -and
                $templateIdentity.GetAttribute("processorArchitecture") -eq $processorArchitecture -and
                $_.ParentNode.GetAttribute("appliesTo") -eq $appliesTo
            })
            if ($matchingBindings.Count -eq 0) {
                $templateStatus = "MissingBinding"
            }
            elseif ($matchingBindings.Count -gt 1) {
                $templateStatus = "AmbiguousBinding"
            }
            else {
                $templateRedirect = $matchingBindings[0].SelectSingleNode("assembly:bindingRedirect", $templateNamespace)
                $templateOldVersion = ""
                $templateNewVersion = ""
                if ($templateRedirect) {
                    $templateOldVersion = $templateRedirect.GetAttribute("oldVersion")
                    $templateNewVersion = $templateRedirect.GetAttribute("newVersion")
                }
                $templateStatus = "RedirectMismatch"
                if ($templateOldVersion -eq $oldVersion -and $templateNewVersion -eq $newVersion) {
                    $templateStatus = "Match"
                }
            }
        }

        if ($OnlyTemplateMismatch -and $templateStatus -eq "Match") { continue }

        [PSCustomObject]@{
            PSTypeName = "D365FO.TOOLS.AssemblyBinding"
            ConfigurationPath = $configurationPath
            AssemblyName = $name
            PublicKeyToken = $publicKeyToken
            Culture = $culture
            ProcessorArchitecture = $processorArchitecture
            AppliesTo = $appliesTo
            OldVersion = $oldVersion
            NewVersion = $newVersion
            AssemblyFile = $assemblyFile
            AssemblyVersion = $assemblyVersion
            AssemblyStatus = $assemblyStatus
            TemplateOldVersion = $templateOldVersion
            TemplateNewVersion = $templateNewVersion
            TemplateStatus = $templateStatus
        }
    }
}