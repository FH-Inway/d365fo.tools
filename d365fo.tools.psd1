#
# Module manifest for module 'D365fo.tools'
#
# Generated by: Motz Jensen & Rasmus Andersen
#
# Generated on: 4/5/2018
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'd365fo.tools.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.2.19'
    
    # Supported PSEditions
    # CompatiblePSEditions = @()
    
    # ID used to uniquely identify this module
    GUID = '7c7b26d4-f764-4cb0-a692-459a0a689dbb'
    
    # Author of this module
    Author = 'Motz Jensen & Rasmus Andersen'
    
    # Company or vendor of this module
    CompanyName = 'Essence Solutions'
    
    # Copyright statement for this module
    Copyright = '(c) 2018 Motz Jensen & Rasmus Andersen. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description   = 'A set of tools that will assist you when working with Dynamics 365 Finance & Operations development / demo machines.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '3.0'
    
    # Name of the Windows PowerShell host required by this module
    PowerShellHostName = ''
    
    # Minimum version of the Windows PowerShell host required by this module
    PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    CLRVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @('.\functions\rename-d365fo.ps1',
    '.\functions\get-decryptedconfigfile.ps1',
    '.\functions\set-startpage.ps1',
    '.\functions\import-aaduser.ps1',
    '.\functions\set-admin.ps1',
    '.\functions\invoke-rearmwindows.ps1',
    '.\functions\get-databaseaccess.ps1',
    '.\functions\get-d365foname.ps1',
    '.\functions\get-productinformation.ps1',
    '.\functions\invoke-dbsync.ps1',
    '.\functions\new-bacpac.ps1',
    '.\functions\import-bacpac.ps1',
    '.\functions\switch-activedatabase.ps1',
    '.\functions\Remove-Database.ps1',
    '.\functions\get-environment.ps1',
    '.\functions\get-userauthenticationdetail.ps1',
    '.\functions\new-bacpacv2.ps1',
    '.\functions\update-user.ps1',
    '.\functions\Invoke-AzureStorageUpload.ps1'
    )
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Rename-D365FO',
                            'Set-StartPage',
                            'Get-DecryptedConfigFile',
                            'Import-AadUser',
                            'Get-DatabaseAccess',
                            'Invoke-ReArmWindows',
                            'Set-Admin',
                            'Get-D365FOName',
                            'Get-ProductInformation',
                            'Invoke-DBSync',
                            'New-BacPac',
                            'Import-BacPac',
                            'Switch-ActiveDatabase',
                            'Remove-Database',
                            'Get-Environment',
                            'Get-UserAuthenticationDetail',
                            'New-BacPacv2',
                            'Update-User',
                            'Invoke-AzureStorageUpload'
                            )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = '*'
    
    # Variables to export from this module
    VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = '*'
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    ModuleList = @()
    
    # List of all files packaged with this module
    FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
    
            PSData = @{
    
                # Tags applied to this module. These help with module discovery in online galleries.
                Tags         = @('d365fo','Dynamics365','D365','Finance&Operations','FinanceOperations','FinanceAndOperations','Dynamics365FO')
    
                # A URL to the license for this module.
                LicenseUri   = "https://opensource.org/licenses/MIT"
    
                # A URL to the main website for this project.
                ProjectUri = 'https://github.com/d365collaborative/d365fo.tools'
    
                # A URL to an icon representing this module.
                # IconUri = ''
    
                # ReleaseNotes of this module
                # ReleaseNotes = ''
                
                # Indicates this is a pre-release/testing version of the module.
                IsPrerelease = 'True'
    
            } # End of PSData hashtable
    
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
    
    }
    
    