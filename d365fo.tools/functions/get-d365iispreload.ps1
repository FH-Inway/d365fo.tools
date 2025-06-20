﻿
<#
    .SYNOPSIS
        Gets IIS Preload status for the AOSService application pool and website.
        
    .DESCRIPTION
        Returns the current IIS Preload configuration for the AOSService application:
        - Application Pool Start Mode
        - Idle Time-out
        - Website Preload Enabled
        - doAppInitAfterRestart (if Application Initialization is installed)
        
    .OUTPUTS
        System.Management.Automation.PSCustomObject
        A custom object containing the following properties:
        - AppPool: Name of the application pool (AOSService)
        - StartMode: Start mode of the application pool (e.g., AlwaysRunning)
        - IdleTimeout: Idle timeout of the application pool (e.g., 00:00:00)
        - Site: Name of the website (AOSService)
        - PreloadEnabled: Indicates if preload is enabled for the website (True/False)
        - DoAppInitAfterRestart: Indicates if doAppInitAfterRestart is enabled (if Application Initialization is installed)
        - PreloadPage: The initialization page configured for preload (if any)
        - IISApplicationInitFeature: State of the IIS Application Initialization feature (Installed/Not installed)
        
    .EXAMPLE
        PS C:\> Get-D365IISPreload
        
        Retrieves the IIS Preload configuration for the AOSService application pool and website.
        
    .NOTES
        Author: Florian Hopfner (FH-Inway)
        Based on Denis Trunin's article "Enable IIS Preload to Speed Up Restart After X++ Compile" (https://www.linkedin.com/pulse/enable-iis-preload-speed-up-restart-after-x-compile-denis-trunin-86j5c)
        Written with GitHub Copilot GPT-4.1, mostly in agent mode. See commits for prompts.
        
    .LINK
        Enable-D365IISPreload
        
    .LINK
        Disable-D365IISPreload
#>
function Get-D365IISPreload {
    [CmdletBinding()]
    param ()

    if (-not (Get-Module -ListAvailable -Name WebAdministration)) {
        Write-PSFMessage -Level Warning -Message "The 'WebAdministration' module is not installed. Please install it with: Install-WindowsFeature -Name Web-WebServer -IncludeManagementTools or Install-Module -Name WebAdministration -Scope CurrentUser"
        return
    }

    Import-Module WebAdministration -ErrorAction Stop

    $iisAppInitFeature = Get-WindowsFeature -Name Web-AppInit -ErrorAction SilentlyContinue
    $iisAppInitState = if ($iisAppInitFeature -and $iisAppInitFeature.Installed) { 'Installed' } else { 'Not installed' }

    $appPool = "AOSService"
    $site = "AOSService"

    $startModeProperty = Get-ItemProperty "IIS:\AppPools\$appPool" -Name startMode
    $startMode = $startModeProperty.Trim() # Ensure we get the value as a string without additional NoteProperty
    $idleTimeoutValue = (Get-ItemProperty "IIS:\AppPools\$appPool" -Name processModel.idleTimeout).Value
    $idleTimeout = if ($idleTimeoutValue -eq [TimeSpan]::Zero) { "0" } else { $idleTimeoutValue.ToString() }
    $preloadEnabled = (Get-ItemProperty "IIS:\Sites\$site" -Name applicationDefaults.preloadEnabled).Value

    $getDoAppInitParams = @{
        pspath      = 'MACHINE/WEBROOT/APPHOST'
        filter      = 'system.webServer/applicationInitialization'
        name        = 'doAppInitAfterRestart'
        location    = $site
        ErrorAction = 'Stop'
    }
    $doAppInitAfterRestart = $null
    try {
        $doAppInitAfterRestart = (Get-WebConfigurationProperty @getDoAppInitParams).Value
    } catch {
        $doAppInitAfterRestart = "Not available"
    }

    $getInitPagesParams = @{
        pspath      = 'MACHINE/WEBROOT/APPHOST'
        filter      = 'system.webServer/applicationInitialization'
        name        = '.'
        location    = $site
        ErrorAction = 'Stop'
    }
    $preloadPage = $null
    try {
        $initPages = Get-WebConfigurationProperty @getInitPagesParams
        if ($initPages -and $initPages.Collection -and $initPages.Collection.Count -gt 0) {
            $preloadPage = $initPages.Collection[0].initializationPage
        } else {
            $preloadPage = "Not configured"
        }
    } catch {
        $preloadPage = "Not available"
    }

    [PSCustomObject]@{
        AppPool = $appPool
        StartMode = $startMode
        IdleTimeout = $idleTimeout
        Site = $site
        PreloadEnabled = $preloadEnabled
        DoAppInitAfterRestart = $doAppInitAfterRestart
        PreloadPage = $preloadPage
        IISApplicationInitFeature = $iisAppInitState
    }
}