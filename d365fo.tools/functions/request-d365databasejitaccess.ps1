<#
    .SYNOPSIS
        Request just in time (JIT) database access for a unified development environment (UDE)

    .DESCRIPTION
        Utilize the D365FO Power Platform OData API to request just in time access (JIT) to a UDE database

        This will allow you to get temporary database credentials for connecting to the database directly

    .PARAMETER Url
        URL / URI for the D365FO Power Platform environment that provides the JIT access API.

        Note: This is not the URL of the D365FO environment itself (aka the Finance and Operations URL). Instead, it is the URL of the Power Platform environment (aka the Environment URL) that the D365FO environment is integrated with.

        For example: "https://operations-acme-uat.crm4.dynamics.com/"

    .PARAMETER ClientId
        The ClientId obtained from the Azure Portal when you created a Registered Application

    .PARAMETER ClientSecretAsPlainString
        The ClientSecret obtained from the Azure Portal when you created a Registered Application

        This is the plain text version of the ClientSecret parameter.

        Either ClientSecretAsPlainString, ClientSecretAsSecureString, or Credential must be provided.

    .PARAMETER ClientSecretAsSecureString
        The ClientSecret obtained from the Azure Portal when you created a Registered Application

        This is the secure string version of the ClientSecret parameter.

        Either ClientSecretAsPlainString, ClientSecretAsSecureString, or Credential must be provided.

    .PARAMETER Credential
        The Credential object containing Username (ClientId) and Password (ClientSecret)

        The Username will be used as ClientId
        The Password will be used as ClientSecret

        Either ClientSecretAsPlainString, ClientSecretAsSecureString, or Credential must be provided.

    .PARAMETER Tenant
        Azure Active Directory (AAD) tenant id (Guid) that the D365FO environment is connected to, that you want to access

    .PARAMETER ClientIPAddress
        The IP address of the client that needs database access

        Default value is "127.0.0.1" which will be replaced with the public IP address of the client as determined by querying "https://icanhazip.com"

    .PARAMETER Role
        The database role to assign to the JIT access

        Valid options are "Reader" and "Writer"

        Default value is "Reader"

    .PARAMETER Reason
        The reason for requesting JIT database access

        Default value is "Administrative access via d365fo.tools"

    .PARAMETER RawOutput
        Instructs the cmdlet to include the outer structure of the response received from the endpoint

        The output will still be a PSCustomObject

    .PARAMETER OutputAsJson
        Instructs the cmdlet to convert the output to a Json string

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecretAsPlainString "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522"

        This will request JIT database access for the D365FO environment.
        It will use the client's IP address, role "Reader", and reason "Administrative access via d365fo.tools".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the "https://login.microsoftonline.com/e674da86-7ee5-40a7-b777-1111111111111/oauth2/token" url with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecretAsPlainString parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecretAsPlainString "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -ClientIPAddress "192.168.1.100" -Role "Writer" -Reason "Development work"

        This will request JIT database access for the D365FO environment with Writer privileges.
        It will use the client IP address "192.168.1.100", role "Writer", and reason "Development work".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecretAsPlainString parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecretAsPlainString "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -OutputAsJson

        This will request JIT database access for the D365FO environment and display the result as json.
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecretAsPlainString parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .EXAMPLE
        PS C:\> $clientSecretSecure = Read-Host -AsSecureString "Enter the Client Secret"
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecretAsSecureString $clientSecretSecure

        This will prompt the user to enter the client secret securely (the input will be masked).
        Then it will request JIT database access for the D365FO environment using the secure string for authentication.
        It will use the client's IP address, role "Reader", and reason "Administrative access via d365fo.tools".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the client secret provided through the secure prompt.

    .EXAMPLE
        PS C:\> $credential = Get-Credential -UserName "dea8d7a9-1602-4429-b138-111111111111" -Message "Enter the Client Secret"
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -Credential $credential

        This will prompt the user to enter the client secret through a secure credential dialog (using the ClientId as the username).
        Then it will request JIT database access for the D365FO environment using the credential for authentication.
        It will use the client's IP address, role "Reader", and reason "Administrative access via d365fo.tools".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the client id and secret provided through the credential object.

    .NOTES
        Tags: JIT, Database, Access, UDE, OData, RestApi

        Author: Florian Hopfner (@FH-Inway)

#>
function Request-D365DatabaseJITAccess {
    [CmdletBinding(DefaultParameterSetName = 'ByClientSecretAsPlainString')]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Url,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByClientSecretAsPlainString')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ByClientSecretAsSecureString')]
        [string] $ClientId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByClientSecretAsPlainString')]
        [string] $ClientSecretAsPlainString,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByClientSecretAsSecureString')]
        [System.Security.SecureString] $ClientSecretAsSecureString,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByCredential')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory = $true)]
        [string] $Tenant, # TODO This could be preset from $Script.TenantId once UDE support is added (see https://github.com/d365collaborative/d365fo.tools/pull/868)

        [string] $ClientIPAddress = "127.0.0.1",

        [ValidateSet("Reader", "Writer")]
        [string] $Role = "Reader",

        [string] $Reason = "Administrative access via d365fo.tools",

        [switch] $RawOutput,

        [switch] $OutputAsJson
    )

    begin {
        # Extract ClientId and ClientSecret from credential if provided
        if ($PSCmdlet.ParameterSetName -eq 'ByCredential') {
            $ClientId = $Credential.UserName
            $ClientSecretAsPlainString = $Credential.GetNetworkCredential().Password
        }
        # Convert SecureString to plain text if ClientSecretAsSecureString is provided
        elseif ($PSCmdlet.ParameterSetName -eq 'ByClientSecretAsSecureString') {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientSecretAsSecureString)
            $ClientSecretAsPlainString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }

        # Clean up the URL to ensure it ends with a slash
        if (-not $Url.EndsWith('/')) {
            $Url = $Url + '/'
        }

        # Replace default IP address with IP address from icanhazip.com
        if ($ClientIPAddress -eq "127.0.0.1") {
            try {
                $ClientIPAddress = (Invoke-RestMethod -Uri "https://icanhazip.com" -UseBasicParsing).Trim()
                Write-PSFMessage -Level Verbose -Message "Detected public IP address: $ClientIPAddress"
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Could not determine public IP address from icanhazip.com. Falling back to default IP address: $ClientIPAddress"
            }
        }
    }

    process {
        $bearerParms = @{
            Resource        = $Url
            ClientId        = $ClientId
            ClientSecret    = $ClientSecretAsPlainString
            AuthProviderUri = "https://login.microsoftonline.com/$Tenant/oauth2/token"
        }

        $bearer = Invoke-ClientCredentialsGrant @bearerParms | Get-BearerToken

        $headers = @{
            'Authorization' = $bearer
            'Accept'        = 'application/json'
            'Content-Type'  = 'application/json; charset=utf-8'
        }

        $requestUrl = $Url + "api/data/v9.2/msprov_getfinopssqljitaccessasync"

        $body = @{
            "sqljitclientipaddress" = $ClientIPAddress
            "sqljitreason"          = $Reason
            "sqljitrole"            = $Role
        } | ConvertTo-Json -Depth 3

        try {
            Write-PSFMessage -Level Verbose -Message "Requesting JIT database access from endpoint: $requestUrl"
            Write-PSFMessage -Level Verbose -Message "Request body: $body"

            $response = Invoke-RestMethod -Uri $requestUrl -Method Post -Headers $headers -Body $body

            $result = $response
            if (-not $RawOutput) {
                # Extract the relevant information from the response
                $selectParams = @{
                    TypeName = "D365FO.TOOLS.UDE.JITDatabaseAccess"
                    Property = @{Name = "SQLJITCredential"; Expression = { 
                        $password = $_.sqljitpassword | ConvertTo-SecureString -AsPlainText -Force
                        New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($_.sqljitusername, $password)
                        }},
                        "servername as ServerName",
                        "databasename as DatabaseName",
                        "databasetype as DatabaseType",
                        "ipaddress as IPAddress",
                        "sqljitrole as SQLJITRole",
                        "sqljitexpiration as SQLJITExpirationTime to DateTime",
                        "operationhistoryid as OperationHistoryId"
                }
                $result = $response | Select-PSFObject @selectParams
            }

            if ($OutputAsJson) {
                $result = $result | ConvertTo-Json -Depth 10
            }

            $result
        }
        catch {
            Write-PSFMessage -Level Host -Message "Something went wrong while requesting JIT database access" -Exception $PSItem.Exception
            Stop-PSFFunction -Message "Stopping because of errors" -StepsUpward 1
            return
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -ne 'ByClientSecretAsPlainString') {
            # Clear sensitive variables
            $ClientSecretAsPlainString = $null
        }
    }
}