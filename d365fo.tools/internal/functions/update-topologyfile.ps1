﻿
<#
    .SYNOPSIS
        Update the topology file

    .DESCRIPTION
        Update the topology file based on the already installed list of services on the machine

    .PARAMETER Path
        Path to the folder where the Microsoft.Dynamics.AX.AXInstallationInfo.dll assembly is located

        Should only contain a path to a folder, not a file

    .PARAMETER TopologyFile
        Path to the topology file to update

        If not specified, the default topology file will be used

    .PARAMETER IncludeFallbackRetailServiceModels
        Include fallback retail service models in the topology file

        This parameter is to support backward compatibility in this scenario:
        Installing the first update on a local VHD where the information about the installed service
        models may not be available and where the retail components are installed.
        More information about this can be found at https://github.com/d365collaborative/d365fo.tools/issues/878

    .PARAMETER ForceFallbackServiceModels
        Force the use of the fallback list of known service model names

        This parameter supports update scenarios primarily on local VHDs where the information about
        the installed service models may be incomplete. In such a case, the user receives a warning
        and a suggestion to use this parameter.

    .EXAMPLE
        PS C:\> Update-TopologyFile -Path "c:\temp\UpdatePackageFolder" -TopologyFile "c:\temp\d365fo.tools\DefaultTopologyData.xml"

        This will update the "c:\temp\d365fo.tools\DefaultTopologyData.xml" file with all the installed services on the machine.

    .NOTES
        # Credit http://dev.goshoom.net/en/2016/11/installing-deployable-packages-with-powershell/

        Author: Tommy Skaue (@Skaue)
        Author: Mötz Jensen (@Splaxi)
        Author: Florian Hopfner (@FH-Inway)

#>
function Update-TopologyFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [string]$TopologyFile,

        [switch]$IncludeFallbackRetailServiceModels,

        [switch]$ForceFallbackServiceModels
    )

    if (-not $TopologyFile) {
        $topologyFile = Join-Path $Path 'DefaultTopologyData.xml'
    }

    Write-PSFMessage -Level Verbose "Updating topology file: $topologyFile"

    [xml]$xml = Get-Content $topologyFile
    $machine = $xml.TopologyData.MachineList.Machine
    $machine.Name = $env:computername

    $serviceModelList = $xml.SelectSingleNode("//ServiceModelList")
    $null = $serviceModelList.RemoveAll()

    $models = Get-InstalledServiceModelNameList -Path $Path
    $params = @{
        InstalledModels = $models
        TopologyFile = $topologyFile
        IncludeFallbackRetailServiceModels = $IncludeFallbackRetailServiceModels
        ForceFallbackServiceModels = $ForceFallbackServiceModels
    }
    $models = Repair-InstalledServiceModelIssue @params

    foreach ($name in $models) {
        $element = $xml.CreateElement('string')
        $element.InnerText = $name
        $serviceModelList.AppendChild($element)
    }

    $xml.Save($topologyFile)

    $true
}

function Get-InstalledServiceModelNameList {
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Write-PSFMessage -Level Verbose "Getting installed service models"

    $Files2Process = New-Object -TypeName "System.Collections.ArrayList"
    $null = $Files2Process.Add((Join-Path $Path 'Microsoft.Dynamics.AX.AXInstallationInfo.dll'))
    Import-AssemblyFileIntoMemory -Path $($Files2Process.ToArray())

    $models = [Microsoft.Dynamics.AX.AXInstallationInfo.AXInstallationInfo]::GetInstalledServiceModel()
    $installedModelNames = $models | ForEach-Object {
        $_.Name
     }
     $installedModelNames
}

function Repair-InstalledServiceModelIssue {
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$InstalledModels,

        [string]$TopologyFile,

        [switch]$IncludeFallbackRetailServiceModels,

        [switch]$ForceFallbackServiceModels
    )

    Write-PSFMessage -Level Verbose "Handling installed service model issues"

    $models = $InstalledModels
    $useFallbackServiceModels = $false
    $fallbackServiceModels = $Script:FallbackInstallationCoreServiceModelNames

    if ($null -eq $installedModels -or $installedModels.Count -eq 0) {
        Write-PSFMessage -Level Warning "No installed service models found."
        $useFallbackServiceModels = $true
    }

    # Compare models and fallback list of known service model names
    $fallbackModelsNotInInstalledList = $fallbackServiceModels | Where-Object { $_ -notin $models }
    if ($fallbackModelsNotInInstalledList.Count -gt 0) {
        Write-PSFMessage -Level Warning "The following service models are in the fallback list of known service model names, but not listed as installed: $($fallbackModelsNotInInstalledList -join ', ')"
        if ($ForceFallbackServiceModels) {
            $useFallbackServiceModels = $true
        }
        else {
            Write-PSFMessage -Level Output "If you want to use the fallback list, please use the -ForceFallbackServiceModels switch."
        }
    }

    if ($useFallbackServiceModels) {
        Write-PSFMessage -Level Output "Using fallback list of known service model names."
        $serviceModelNames = $fallbackServiceModels
        if ($IncludeFallbackRetailServiceModels) {
            $serviceModelNames += $Script:FallbackInstallationRetailServiceModelNames
        }
        else {
            Write-PSFMessage -Level Output "The fallback list of known service model names does not include the retail service models. To include them, use the -IncludeFallbackRetailServiceModels switch. See https://github.com/d365collaborative/d365fo.tools/issues/878 for more information."
        }
        $models = $serviceModelNames
    }

    $models
}