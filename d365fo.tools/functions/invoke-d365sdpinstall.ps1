﻿
<#
    .SYNOPSIS
        Install a Software Deployable Package (SDP)
        
    .DESCRIPTION
        A cmdlet that wraps some of the cumbersome work into a streamlined process.
        The process for a legacy (i.e. non unified) environment are detailed in the Microsoft documentation here:
        https://docs.microsoft.com/en-us/dynamics365/unified-operations/dev-itpro/deployment/install-deployable-package
        
    .PARAMETER Path
        Path to the update package that you want to install into the environment
        
        The cmdlet supports a path to a zip-file or directory with the unpacked contents.
        
    .PARAMETER MetaDataDir
        The path to the meta data directory for the environment
        
        Default path is the same as the aos service PackagesLocalDirectory
        
    .PARAMETER QuickInstallAll
        Use this switch to let the runbook reside in memory. You will not get a runbook on disc which you can examine for steps
        
    .PARAMETER DevInstall
        Use this when running on developer box without administrator privileges (Run As Administrator)
        
    .PARAMETER Command
        The command you want the cmdlet to execute when it runs the AXUpdateInstaller.exe
        
        Valid options are:
        SetTopology
        Generate
        Import
        Execute
        RunAll
        ReRunStep
        SetStepComplete
        Export
        VersionCheck
        
        The default value is "SetTopology"
        
    .PARAMETER Step
        The step number that you want to work against
        
    .PARAMETER RunbookId
        The runbook id of the runbook that you want to work against
        
        Default value is "Runbook"
        
    .PARAMETER LogPath
        The path where the log file(s) will be saved
        
        When running without the ShowOriginalProgress parameter, the log files will be the standard output and the error output from the underlying tool executed
        
    .PARAMETER ShowOriginalProgress
        Instruct the cmdlet to show the standard output in the console
        
        Default is $false which will silence the standard output
        
    .PARAMETER OutputCommandOnly
        Instruct the cmdlet to only output the command that you would have to execute by hand
        
        Will include full path to the executable and the needed parameters based on your selection
        
    .PARAMETER TopologyFile
        Provide a custom topology file to use. By default, the cmdlet will use the DefaultTopologyData.xml file in the package directory.
        
    .PARAMETER UseExistingTopologyFile
        Use this switch to indicate that the topology file is already updated and should not be updated again.
        
    .PARAMETER UnifiedDevelopmentEnvironment
        Use this switch to install the package in a Unified Development Environment (UDE).
        
    .PARAMETER IncludeFallbackRetailServiceModels
        Include fallback retail service models in the topology file
        
        This parameter is to support backward compatibility in this scenario:
        Installing the first update on a local VHD where the information about the installed service
        models may not be available and where the retail components are installed.
        More information about this can be found at https://github.com/d365collaborative/d365fo.tools/issues/878
        
    .PARAMETER Force
        Instruct the cmdlet to overwrite the "extracted" folder if it exists
        
        Used when the input is a zip file, that will auto extract to a folder named like the zip file.
        
    .PARAMETER ForceFallbackServiceModels
        Force the use of the fallback list of known service model names
        
        This parameter supports update scenarios primarily on local VHDs where the information about
        the installed service models may be incomplete. In such a case, the user receives a warning
        and a suggestion to use this parameter.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\package.zip" -QuickInstallAll
        
        This will install the package contained in the c:\temp\package.zip file using a runbook in memory while executing.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -DevInstall
        
        This will install the extracted package in c:\temp\ using a runbook in memory while executing.
        
        This command is to be used on Microsoft Hosted Tier1 development environment, where you don't have access to the administrator user account on the vm.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command SetTopology
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command Generate -RunbookId 'MyRunbook'
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command Import -RunbookId 'MyRunbook'
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command Execute -RunbookId 'MyRunbook'
        
        Manual operations that first create Topology XML from current environment, then generate runbook with id 'MyRunbook', then import it and finally execute it.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command RunAll
        
        Create Topology XML from current environment. Using default runbook id 'Runbook' and run all the operations from generate, to import to execute.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command RerunStep -Step 18 -RunbookId 'MyRunbook'
        
        Rerun runbook with id 'MyRunbook' from step 18.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command SetStepComplete -Step 24 -RunbookId 'MyRunbook'
        
        Mark step 24 complete in runbook with id 'MyRunbook' and continue the runbook from the next step.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command SetTopology -TopologyFile "c:\temp\MyTopology.xml"
        
        Update the MyTopology.xml file with all the installed services on the machine.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -Command RunAll -TopologyFile "c:\temp\MyTopology.xml" -UseExistingTopologyFile
        
        Run all manual steps in one single operation using the MyTopology.xml file. The topology file is not updated.
        
    .EXAMPLE
        PS C:\> Invoke-D365SDPInstall -Path "c:\temp\" -MetaDataDir "c:\MyRepository\Metadata" -UnifiedDevelopmentEnvironment
        
        Install the modules contained in the c:\temp\ directory into the c:\MyRepository\Metadata directory.
        
    .EXAMPLE
        Invoke-D365SDPInstall -Path "c:\temp\" -Command RunAll -IncludeFallbackRetailServiceModels
        
        Create Topology XML from current environment. If the current environment does not have the information about the installed service models, a fallback list of known service model names will be used.
        This fallback list includes the retail service models.
        Using default runbook id 'Runbook' and run all the operations from generate, to import to execute.
        
    .EXAMPLE
        Invoke-D365SDPInstall -Path "c:\temp\" -Command RunAll -ForceFallbackServiceModels
        
        Create Topology XML from current environment. If the current environment does have no or only partial information about the installed service models, a fallback list of known service model names will be used.
        This fallback list does not include the retail service models.
        Using default runbook id 'Runbook' and run all the operations from generate, to import to execute.
        
    .NOTES
        Author: Tommy Skaue (@skaue)
        Author: Mötz Jensen (@Splaxi)
        Author: Florian Hopfner (@FH-Inway)
        
        Inspired by blogpost http://dev.goshoom.net/en/2016/11/installing-deployable-packages-with-powershell/
        
    .LINK
        Invoke-D365SDPInstallUDE
        
#>
function Invoke-D365SDPInstall {
    [CmdletBinding(DefaultParameterSetName = 'QuickInstall')]
    param (
        [Parameter(Mandatory = $True, Position = 1 )]
        [Alias('Hotfix')]
        [Alias('File')]
        [string] $Path,

        [Parameter(Mandatory = $false, Position = 2 )]
        [string] $MetaDataDir = "$Script:MetaDataDir",

        [Parameter(Mandatory = $false, ParameterSetName = 'QuickInstall', Position = 3 )]
        [switch] $QuickInstallAll,

        [Parameter(Mandatory = $false, ParameterSetName = 'DevInstall', Position = 3 )]
        [switch] $DevInstall,

        [Parameter(Mandatory = $true, ParameterSetName = 'Manual', Position = 3 )]
        [ValidateSet('SetTopology', 'Generate', 'Import', 'Execute', 'RunAll', 'ReRunStep', 'SetStepComplete', 'Export', 'VersionCheck')]
        [string] $Command = 'SetTopology',

        [Parameter(Mandatory = $false, Position = 4 )]
        [int] $Step,

        [Parameter(Mandatory = $false, Position = 5 )]
        [string] $RunbookId = "Runbook",

        [Alias('LogDir')]
        [string] $LogPath = $(Join-Path -Path $Script:DefaultTempPath -ChildPath "Logs\SdpInstall"),

        [switch] $ShowOriginalProgress,

        [switch] $OutputCommandOnly,

        [string] $TopologyFile = "DefaultTopologyData.xml",

        [switch] $UseExistingTopologyFile,

        [Parameter(ParameterSetName = 'UDEInstall')]
        [switch] $UnifiedDevelopmentEnvironment,

        [switch] $IncludeFallbackRetailServiceModels,

        [switch] $Force,

        [switch] $ForceFallbackServiceModels
    )

    if ($UnifiedDevelopmentEnvironment) {
        Invoke-D365SDPInstallUDE -Path $Path -MetaDataDir $MetaDataDir -LogPath $LogPath
        return
    }

    if ((Get-Process -Name "devenv" -ErrorAction SilentlyContinue).Count -gt 0) {
        Write-PSFMessage -Level Host -Message "It seems that you have a <c='em'>Visual Studio</c> running. Please ensure <c='em'>exit</c> Visual Studio and run the cmdlet again."
        Stop-PSFFunction -Message "Stopping because of running Visual Studio."
        return
    }

    Test-AssembliesLoaded

    if (Test-PSFFunctionInterrupt) {
        Write-PSFMessage -Level Host -Message "It seems that you have executed some cmdlets that required to <c='em'>load</c> some Dynamics 356 Finance & Operations <c='em'>assemblies</c> into memory. Please <c='em'>close and restart</c> you PowerShell session / console, and <c='em'>start a fresh</c>. Please note that you should execute the failed command <c='em'>immediately</c> after importing the module."
        Stop-PSFFunction -Message "Stopping because of loaded assemblies."
        return
    }

    $arrRunbookIds = Get-D365Runbook -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Get-D365RunbookId

    if (($Command -eq "RunAll") -and ($arrRunbookIds.Runbookid -contains $RunbookId)) {
        Write-PSFMessage -Level Host -Message "It seems that you have entered an <c='em'>already used RunbookId</c>. Please consider if you are <c='em'>trying to re-run some steps</c> or simply pass <c='em'>another RunbookId</c>."
        Stop-PSFFunction -Message "Stopping because of RunbookId already used on this machine."
        return
    }

    Invoke-TimeSignal -Start

    #Test if input is a zipFile that needs to be extracted first
    if ($Path.EndsWith(".zip")) {
        Unblock-File -Path $Path

        $extractedPath = $path.Remove($path.Length - 4)

        if (-not $Force) {
            if (-not (Test-PathExists -Path $extractedPath -Type Container -ShouldNotExist)) {
                Write-PSFMessage -Level Host -Message "The directory at the <c='em'>$extractedPath</c> location already exists. If you want to override it - set the <c='em'>Force</c> parameter to clear the folder and extract the content into it."
                Stop-PSFFunction -Message "Stopping because output path was already present."
                return
            }
        }

        Get-ChildItem -Path $extractedPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false

        # To allow the file system to flush the files
        # Allows the human to see the folder being wiped
        Start-Sleep -Seconds 2

        Expand-Archive -Path $Path -DestinationPath $extractedPath -Force
        $Path = $extractedPath
    }

    # Input is a relative path which needs to be converted to an absolute path.
    # see https://powershellmagazine.com/2013/01/16/pstip-check-if-the-path-is-relative-or-absolute/
    if (-not ([System.IO.Path]::IsPathRooted($Path) -or (Split-Path -Path $Path -IsAbsolute))) {
        $currentPath = Get-Location
        # https://stackoverflow.com/a/13847304/2720554
        $absolutePath = Join-Path -Path $currentPath -ChildPath $Path
        $absolutePath = [System.IO.Path]::GetFullPath($absolutePath)
        Write-PSFMessage -Level Verbose "Updating path to '$absolutePath' as relative paths are not supported"
        $Path = $absolutePath
    }

    $executable = Join-Path $Path "AXUpdateInstaller.exe"


    if (-not ([System.IO.Path]::IsPathRooted($TopologyFile) -or (Split-Path -Path $TopologyFile -IsAbsolute))) {
        $TopologyFile = Join-Path -Path $Path -ChildPath $TopologyFile
    }

    if (-not (Test-PathExists -Path $topologyFile, $executable -Type Leaf)) { return }

    Get-ChildItem -Path $Path -Recurse | Unblock-File

    if ($QuickInstallAll) {
        Write-PSFMessage -Level Verbose "Using QuickInstallAll mode"
        $params = "quickinstallall"

        Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath
    }
    elseif ($DevInstall) {
        Write-PSFMessage -Level Verbose "Using DevInstall mode"
        $params = "devinstall"

        Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath
    }
    else {
        $Command = $Command.ToLowerInvariant()
        $runbookFile = Join-Path $Path "$runbookId.xml"
        $serviceModelFile = Join-Path $Path 'DefaultServiceModelData.xml'

        if ($Command -eq 'runall') {
            Write-PSFMessage -Level Verbose "Running all manual steps in one single operation"

            #Update topology file (first command)
            if (-not $UseExistingTopologyFile) {
                $params = @{
                    Path = $Path
                    TopologyFile = $TopologyFile
                    IncludeFallbackRetailServiceModels = $IncludeFallbackRetailServiceModels
                    ForceFallbackServiceModels = $ForceFallbackServiceModels
                }
                $ok = Update-TopologyFile @params
                if (-not $ok) {
                    Write-PSFMessage -Level Warning "Failed to update topology file."
                    return
                }
            }

            $params = @(
                "generate"
                "-runbookId=`"$runbookId`""
                "-topologyFile=`"$topologyFile`""
                "-serviceModelFile=`"$serviceModelFile`""
                "-runbookFile=`"$runbookFile`""
            )

            #Generate (second command)
            Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath

            if (Test-PSFFunctionInterrupt) { return }

            $params = @(
                "import"
                "-runbookFile=`"$runbookFile`""
            )

            Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath

            if (Test-PSFFunctionInterrupt) { return }

            $params = @(
                "execute"
                "-runbookId=`"$runbookId`""
            )

            Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath

            if (Test-PSFFunctionInterrupt) { return }

            Write-PSFMessage -Level Verbose "All manual steps complete."
        }
        else {
            $RunCommand = $true
            switch ($Command) {
                'settopology' {
                    Write-PSFMessage -Level Verbose "Updating topology file xml."

                    if ($UseExistingTopologyFile) {
                        Write-PSFMessage -Level Warning "The SetTopology command is used to update a topology file. The UseExistingTopologyFile switch should not be used with this command."
                        return
                    }
                    $params = @{
                        Path = $Path
                        TopologyFile = $TopologyFile
                        IncludeFallbackRetailServiceModels = $IncludeFallbackRetailServiceModels
                        ForceFallbackServiceModels = $ForceFallbackServiceModels
                    }
                    $ok = Update-TopologyFile @params
                    if (-not $ok) {
                        Write-PSFMessage -Level Warning "Failed to update topology file."
                    }
                    $RunCommand = $false
                }
                'generate' {
                    Write-PSFMessage -Level Verbose "Generating runbook file."

                    $params = @(
                        "generate"
                        "-runbookId=`"$runbookId`""
                        "-topologyFile=`"$topologyFile`""
                        "-serviceModelFile=`"$serviceModelFile`""
                        "-runbookFile=`"$runbookFile`""
                    )
                }
                'import' {
                    Write-PSFMessage -Level Verbose "Importing runbook file."

                    $params = @(
                        "import"
                        "-runbookfile=`"$runbookFile`""
                    )
                }
                'execute' {
                    Write-PSFMessage -Level Verbose "Executing runbook file."

                    $params = @(
                        "execute"
                        "-runbookId=`"$runbookId`""
                    )
                }
                'rerunstep' {
                    Write-PSFMessage -Level Verbose "Rerunning runbook step number $step."

                    $params = @(
                        "execute"
                        "-runbookId=`"$runbookId`""
                        "-rerunstep=$step"
                    )
                }
                'setstepcomplete' {
                    Write-PSFMessage -Level Verbose "Marking step $step complete and continuing from next step."

                    $params = @(
                        "execute"
                        "-runbookId=`"$runbookId`""
                        "-setstepcomplete=$step"
                    )
                }
                'export' {
                    Write-PSFMessage -Level Verbose "Exporting runbook for reuse."

                    $params = @(
                        "export"
                        "-runbookId=`"$runbookId`""
                        "-runbookfile=`"$runbookFile`""
                    )
                }
                'versioncheck' {
                    Write-PSFMessage -Level Verbose "Running version check on runbook."

                    $params = @(
                        "execute"
                        "-runbookId=`"$runbookId`""
                        "-versioncheck=true"
                    )
                }
            }

            if ($RunCommand) {
                Invoke-Process -Executable $executable -Params $params -ShowOriginalProgress:$ShowOriginalProgress -OutputCommandOnly:$OutputCommandOnly -LogPath $LogPath

                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }

    Invoke-TimeSignal -End

}