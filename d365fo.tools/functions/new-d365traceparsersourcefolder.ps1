<#
    .SYNOPSIS
        Creates a folder with symbolic links for both system and custom metadata for Trace Parser
        
    .DESCRIPTION
        Creates a new folder under "%localappdata%\Microsoft\Dynamics365\RuntimeSymLinks\{yourConfig}\xxceTraceParserPackagesLocalDirectory"
        with symbolic links to both system and custom metadata, so that Trace Parser can display the correct source code for both.
        
        This solves the issue where Trace Parser can only show either system or custom metadata, but not both at the same time.
        After running this function, point Trace Parser to the new folder using "File > select local metadata repo".
        
    .PARAMETER ConfigName
        Name of the configuration folder under "%localappdata%\Microsoft\Dynamics365\RuntimeSymLinks\".
        By default, it will use the most recently modified config folder if not specified.
        
    .PARAMETER OutputFolderName
        Name of the output folder that will be created under the RuntimeSymLinks config path.
        
        Default value is "xxceTraceParserPackagesLocalDirectory"
        
    .PARAMETER CustomMetadataFolderName
        Name of the folder containing custom metadata.
        
        Default value is "ZZZZ__Metadata"
        
    .PARAMETER SystemMetadataFolderName
        Name of the folder containing system metadata.
        
        Default value is "PackagesLocalDirectory"
        
    .PARAMETER Force
        Switch to force removal of existing output folder if it already exists.
        
    .EXAMPLE
        PS C:\> New-D365TraceParserSourceFolder
        
        Creates a new folder with symbolic links to both system and custom metadata in the default location.
        Uses the most recently modified config folder under "%localappdata%\Microsoft\Dynamics365\RuntimeSymLinks\".
        
    .EXAMPLE
        PS C:\> New-D365TraceParserSourceFolder -ConfigName "MyConfig" -Force
        
        Creates a new folder with symbolic links to both system and custom metadata in the "MyConfig" folder.
        Will remove the existing output folder if it already exists.
        
    .NOTES
        Tags: Trace Parser, Debugging, Development, Source Code, Metadata
        
        Author: Brad Bateman
        Author: Mötz Jensen (@Splaxi)
        
#>
function New-D365TraceParserSourceFolder {
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [string] $ConfigName,

        [string] $OutputFolderName = "xxceTraceParserPackagesLocalDirectory",

        [string] $CustomMetadataFolderName = "ZZZZ__Metadata",

        [string] $SystemMetadataFolderName = "PackagesLocalDirectory",

        [switch] $Force
    )

    begin {
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-PSFMessage -Level Critical -Message "The current PowerShell session is NOT running as ADMINISTRATOR. Symbolic links creation requires administrator rights."
            Stop-PSFFunction -Message "Stopping because the current PowerShell session is NOT running as ADMINISTRATOR."
            return
        }

        $RuntimeSymLinksBasePath = Join-Path $($env:LOCALAPPDATA) -ChildPath "Microsoft\Dynamics365\RuntimeSymLinks"
        
        if (-not (Test-Path $RuntimeSymLinksBasePath)) {
            Write-PSFMessage -Level Critical -Message "RuntimeSymLinks base folder not found: $RuntimeSymLinksBasePath"
            Stop-PSFFunction -Message "Stopping because RuntimeSymLinks base folder was not found."
            return
        }

        if (-not $ConfigName) {
            $ConfigName = (Get-ChildItem "$RuntimeSymLinksBasePath" -Directory | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1).Name
            
            if (-not $ConfigName) {
                Write-PSFMessage -Level Critical -Message "No configuration folders found under $RuntimeSymLinksBasePath"
                Stop-PSFFunction -Message "Stopping because no configuration folders were found."
                return
            }
        }
        
        $RuntimeSymLinksConfigPath = Join-Path $RuntimeSymLinksBasePath -ChildPath $ConfigName
        
        if (-not (Test-Path $RuntimeSymLinksConfigPath)) {
            Write-PSFMessage -Level Critical -Message "RuntimeSymLinks configuration folder not found: $RuntimeSymLinksConfigPath"
            Stop-PSFFunction -Message "Stopping because the specified configuration folder was not found."
            return
        }
        
        $customMetadataSourcePath = Join-Path $RuntimeSymLinksConfigPath $CustomMetadataFolderName
        $systemMetadataSourcePath = Join-Path $RuntimeSymLinksConfigPath $SystemMetadataFolderName
        $targetRootPath = Join-Path $RuntimeSymLinksConfigPath $OutputFolderName
        
        if (-not (Test-Path $customMetadataSourcePath)) {
            Write-PSFMessage -Level Critical -Message "Custom metadata folder not found: $customMetadataSourcePath"
            Stop-PSFFunction -Message "Stopping because custom metadata folder was not found."
            return
        }
        
        if (-not (Test-Path $systemMetadataSourcePath)) {
            Write-PSFMessage -Level Critical -Message "System metadata folder not found: $systemMetadataSourcePath"
            Stop-PSFFunction -Message "Stopping because system metadata folder was not found."
            return
        }

        if (Test-Path $targetRootPath) {
            if ($Force) {
                Write-PSFMessage -Level Verbose -Message "Removing existing target folder: $targetRootPath"
                Remove-Item $targetRootPath -Recurse -Force
            }
            else {
                Write-PSFMessage -Level Critical -Message "Target folder already exists: $targetRootPath. Use -Force to overwrite."
                Stop-PSFFunction -Message "Stopping because target folder already exists. Use -Force to overwrite."
                return
            }
        }
    }
    
    process {
        if (Test-PSFFunctionInterrupt) { return }

        try {
            Write-PSFMessage -Level Verbose -Message "Creating target root directory: $targetRootPath"
            New-Item $targetRootPath -ItemType Directory -Force | Out-Null

            $RepoModelFolders = Get-ChildItem $customMetadataSourcePath -Directory
            $RepoModelFolders += Get-ChildItem $systemMetadataSourcePath -Directory

            $result = foreach ($ModelFolder in $RepoModelFolders) {
                $Target = $ModelFolder.FullName
                $newPath = Join-Path $targetRootPath $($ModelFolder.Name)

                Write-PSFMessage -Level Verbose -Message "Creating symbolic link for $($ModelFolder.Name) to $Target"
                New-Item -ItemType SymbolicLink -Path $targetRootPath -Name $($ModelFolder.Name) -Value $Target -ErrorAction SilentlyContinue

                [PSCustomObject]@{
                    FolderName = $ModelFolder.Name
                    SourcePath = $Target
                    SymlinkPath = $newPath
                }
            }

            Write-PSFMessage -Level Host -Message "Trace Parser source folder created successfully at: $targetRootPath"
            Write-PSFMessage -Level Host -Message "In Trace Parser, go to 'File > select local metadata repo' and select this folder."

            $result
        }
        catch {
            Write-PSFMessage -Level Critical -Message "Error creating symbolic links: $_"
            Stop-PSFFunction -Message "Error occurred during symbolic links creation." -Exception $_.Exception
            return
        }
    }
}
