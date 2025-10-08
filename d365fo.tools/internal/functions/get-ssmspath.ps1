<#
    .SYNOPSIS
        Resolve the full path to ssms.exe (SQL Server Management Studio)

    .DESCRIPTION
        Tries multiple strategies to locate the SQL Server Management Studio executable (ssms.exe):
        1. Reads HKCR registry class command entries used by SSMS URL protocols / shell verbs (ssms.dmx*, ssms.c2s* for newer versions).
        2. Parses the default command values to extract the executable path.
        3. Falls back to a curated list of common installation directories (18+ incl. 21 Release layout).
        4. Optionally considers user provided additional hint paths.

        Returns the first existing path after ordering by the detected (or inferred) version number, descending.

    .PARAMETER AdditionalHintPath
        One or more additional absolute paths (folders or full paths to ssms.exe) to consider during resolution.

    .EXAMPLE
        PS C:\> Get-SSMSPath
        C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Ssms.exe

    .EXAMPLE
        PS C:\> Get-SSMSPath -AdditionalHintPath 'D:\Tools\SSMS\Ssms.exe'

        Will include the supplied path in the candidate list.

    .NOTES
        Author: Copilot (auto-generated helper)
        Inspired by logic in Test-RequestJITAccess.ps1 draft script.

#>
function Get-SSMSPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string[]] $AdditionalHintPath
    )

    Write-PSFMessage -Level Debug -Message "Starting SSMS path discovery." -Target $PSBoundParameters

    # 1. Registry based discovery (patterns reflect different major versions / protocols)
    $registrySearchPatterns = @(
        'Registry::HKEY_CLASSES_ROOT\ssms.dmx*\shell\Open\Command', # SSMS 18 era
        'Registry::HKEY_CLASSES_ROOT\ssms.c2s*\shell\Open\Command'  # SSMS 20/21+
    )

    $regex = '^["]?(?<path>.*ssms\.exe)["]?\s*"%1"'
    $registryCandidates = New-Object System.Collections.Generic.List[string]

    foreach ($pattern in $registrySearchPatterns) {
        Write-PSFMessage -Level Debug -Message "Searching registry with pattern: $pattern" -Target $pattern
        try {
            Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $default = (Get-ItemProperty -Path $_.PsPath -ErrorAction Stop)."(Default)"
                    if ([string]::IsNullOrWhiteSpace($default)) { return }
                    $m = [regex]::Match($default, $regex)
                    if ($m.Success) {
                        $exePath = $m.Groups['path'].Value
                        if (-not [string]::IsNullOrWhiteSpace($exePath)) {
                            Write-PSFMessage -Level Verbose -Message "Found SSMS candidate from registry: $exePath" -Target $exePath
                            $null = $registryCandidates.Add($exePath)
                        }
                    }
                }
                catch {
                    Write-PSFMessage -Level Debug -Message "Failed reading registry command value." -Exception $PSItem.Exception
                }
            }
        }
        catch {
            Write-PSFMessage -Level Debug -Message "Registry pattern enumeration failed." -Exception $PSItem.Exception
        }
    }

    # 2. Well-known default install locations (add new versions as needed)
    $programFiles = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    $wellKnown = foreach ($root in $programFiles) {
        foreach ($major in 21,20,19,18) { # order matters (highest first)
            # SSMS 21+ uses an extra 'Release' segment (observed), include both patterns
            Join-Path -Path $root -ChildPath "Microsoft SQL Server Management Studio $major\\Release\\Common7\\IDE\\Ssms.exe"
            Join-Path -Path $root -ChildPath "Microsoft SQL Server Management Studio $major\\Common7\\IDE\\Ssms.exe"
        }
    }

    # 3. Merge all candidates + user hints
    $allCandidates = New-Object System.Collections.Generic.HashSet[string] ([StringComparer]::OrdinalIgnoreCase)
    foreach ($c in ($registryCandidates + $wellKnown + $AdditionalHintPath)) {
        if ([string]::IsNullOrWhiteSpace($c)) { continue }
        # Normalize to full path if pointing to directory; append ssms.exe
        $candidate = $c
        if ((Test-Path -Path $candidate -PathType Container)) {
            $candidate = Join-Path -Path $candidate -ChildPath 'Ssms.exe'
        }
        $null = $allCandidates.Add($candidate)
    }

    if ($allCandidates.Count -eq 0) {
        Stop-PSFFunction -Message "No SSMS path candidates were produced during discovery." -StepsUpward 1
        return
    }

    # 4. Filter to those that actually exist
    $existing = foreach ($p in $allCandidates) {
        if (Test-Path -Path $p -PathType Leaf) { $p }
    }

    if (-not $existing -or $existing.Count -eq 0) {
        Stop-PSFFunction -Message "Unable to locate SQL Server Management Studio (ssms.exe)." -StepsUpward 1
        return
    }

    # 5. Rank by version (file version if available, else try to parse major version segment from folder name)
    $ranked = $existing | ForEach-Object {
        $fileVersion = $null
        try {
            $fvInfo = (Get-Item $_).VersionInfo
            if ($fvInfo -and ($fvInfo.FileVersionRaw.Major -gt 0)) { $fileVersion = $fvInfo.FileVersionRaw.Major }
        }
        catch {}
        if (-not $fileVersion) {
            if ($_ -match 'Management Studio (?<v>\d{2})') { $fileVersion = [int]$Matches['v'] }
            elseif ($_ -match 'SSMS(?<v>\d{2})') { $fileVersion = [int]$Matches['v'] }
            else { $fileVersion = 0 }
        }
        [PSCustomObject]@{ Path = $_; Version = $fileVersion }
    } | Sort-Object -Property Version -Descending

    $selected = $ranked | Select-Object -First 1
    Write-PSFMessage -Level Verbose -Message "Selected SSMS path: $($selected.Path) (Version heuristic: $($selected.Version))" -Target $selected.Path
    $selected.Path
}
