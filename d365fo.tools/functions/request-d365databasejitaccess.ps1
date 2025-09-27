
<#
    .SYNOPSIS
        Request just in time (JIT) database access for a unified development environment (UDE)

    .DESCRIPTION
        Utilize the D365FO OData API to request just in time access (JIT) to a UDE database

        This will allow you to get temporary database credentials for connecting to the database directly

    .PARAMETER Url
        URL / URI for the D365FO environment you want to access

        If you are working against a D365FO instance, it will be the URL / URI for the instance itself

        This should be the full URL, e.g. "https://operations-acme-uat.crm4.dynamics.com/"

    .PARAMETER ClientId
        The ClientId obtained from the Azure Portal when you created a Registered Application

    .PARAMETER ClientSecret
        The ClientSecret obtained from the Azure Portal when you created a Registered Application

    .PARAMETER Tenant
        Azure Active Directory (AAD) tenant id (Guid) that the D365FO environment is connected to, that you want to access

    .PARAMETER ClientIPAddress
        The IP address of the client that needs database access

        Default value is "127.0.0.1" for localhost access

    .PARAMETER Role
        The database role to assign to the JIT access

        Valid options are "Reader" and "Writer"

        Default value is "Reader"

    .PARAMETER Reason
        The reason for requesting JIT database access

        This is logged for audit purposes

        Default value is "Administrative access via d365fo.tools"

    .PARAMETER RawOutput
        Instructs the cmdlet to include the outer structure of the response received from the endpoint

        The output will still be a PSCustomObject

    .PARAMETER OutputAsJson
        Instructs the cmdlet to convert the output to a Json string

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522"

        This will request JIT database access for the D365FO environment.
        It will use the default client IP address "127.0.0.1", role "Reader", and reason "Administrative access via d365fo.tools".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the "https://login.microsoftonline.com/e674da86-7ee5-40a7-b777-1111111111111/oauth2/token" url with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -ClientIPAddress "192.168.1.100" -Role "Writer" -Reason "Development work"

        This will request JIT database access for the D365FO environment with Writer privileges.
        It will use the client IP address "192.168.1.100", role "Writer", and reason "Development work".
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .EXAMPLE
        PS C:\> Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -OutputAsJson

        This will request JIT database access for the D365FO environment and display the result as json.
        It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
        It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
        It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
        It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

    .NOTES
        Tags: JIT, Database, Access, UDE, OData, RestApi

        Author: Mötz Jensen (@Splaxi)

        This cmdlet is inspired by the PowerShell script provided in GitHub issue for d365fo.tools

#>
function Request-D365DatabaseJITAccess {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Url,

        [Parameter(Mandatory = $true)]
        [string] $ClientId,

        [Parameter(Mandatory = $true)]
        [string] $ClientSecret,

        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [string] $ClientIPAddress = "127.0.0.1",

        [ValidateSet("Reader", "Writer")]
        [string] $Role = "Reader",

        [string] $Reason = "Administrative access via d365fo.tools",

        [switch] $RawOutput,

        [switch] $OutputAsJson
    )

    begin {
        # Clean up the URL to ensure it ends with a slash
        if (-not $Url.EndsWith('/')) {
            $Url = $Url + '/'
        }
    }

    process {
        $bearerParms = @{
            Resource        = $Url
            ClientId        = $ClientId
            ClientSecret    = $ClientSecret
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

            if ($RawOutput) {
                $result = $response
            }
            else {
                # Extract the relevant information from the response
                $result = [PSCustomObject]@{
                    Username         = $response.sqljitusername
                    Password         = $response.sqljitpassword
                    ServerName       = $response.servername
                    DatabaseName     = $response.databasename
                    DatabaseType     = $response.databasetype
                    IPAddress        = $response.ipaddress
                    Role             = $response.sqljitrole
                    ExpirationTime   = $response.sqljitexpiration
                    OperationId      = $response.operationhistoryid
                }
            }

            if ($OutputAsJson) {
                $result | ConvertTo-Json -Depth 10
            }
            else {
                $result
            }
        }
        catch {
            Write-PSFMessage -Level Host -Message "Something went wrong while requesting JIT database access" -Exception $PSItem.Exception
            Stop-PSFFunction -Message "Stopping because of errors" -StepsUpward 1
            return
        }
    }

    end {
    }
}