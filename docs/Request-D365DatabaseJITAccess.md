---
external help file: d365fo.tools-help.xml
Module Name: d365fo.tools
online version:
schema: 2.0.0
---

# Request-D365DatabaseJITAccess

## SYNOPSIS
Request just in time (JIT) database access for a unified development environment (UDE)

## SYNTAX

```
Request-D365DatabaseJITAccess [-Url] <String> [-ClientId] <String> [-ClientSecret] <String>
 [-Tenant] <String> [[-ClientIPAddress] <String>] [[-Role] <String>] [[-Reason] <String>] [-RawOutput]
 [-OutputAsJson] [<CommonParameters>]
```

## DESCRIPTION
Utilize the D365FO OData API to request just in time access (JIT) to a UDE database

This will allow you to get temporary database credentials for connecting to the database directly

## EXAMPLES

### EXAMPLE 1
```
Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522"
```

This will request JIT database access for the D365FO environment.
It will use the default client IP address "127.0.0.1", role "Reader", and reason "Administrative access via d365fo.tools".
It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
It will authenticate against the "https://login.microsoftonline.com/e674da86-7ee5-40a7-b777-1111111111111/oauth2/token" url with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

### EXAMPLE 2
```
Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -ClientIPAddress "192.168.1.100" -Role "Writer" -Reason "Development work"
```

This will request JIT database access for the D365FO environment with Writer privileges.
It will use the client IP address "192.168.1.100", role "Writer", and reason "Development work".
It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

### EXAMPLE 3
```
Request-D365DatabaseJITAccess -Url "https://operations-acme-uat.crm4.dynamics.com/" -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" -OutputAsJson
```

This will request JIT database access for the D365FO environment and display the result as json.
It will contact the D365FO instance specified in the Url parameter: "https://operations-acme-uat.crm4.dynamics.com/".
It will authenticate against the Azure Active Directory with the specified Tenant parameter: "e674da86-7ee5-40a7-b777-1111111111111".
It will authenticate with the specified ClientId parameter: "dea8d7a9-1602-4429-b138-111111111111".
It will authenticate with the specified ClientSecret parameter: "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522".

## PARAMETERS

### -Url
URL / URI for the D365FO environment you want to access

If you are working against a D365FO instance, it will be the URL / URI for the instance itself

This should be the full URL, e.g. "https://operations-acme-uat.crm4.dynamics.com/"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
The ClientId obtained from the Azure Portal when you created a Registered Application

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The ClientSecret obtained from the Azure Portal when you created a Registered Application

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant
Azure Active Directory (AAD) tenant id (Guid) that the D365FO environment is connected to, that you want to access

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientIPAddress
The IP address of the client that needs database access

Default value is "127.0.0.1" for localhost access

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 127.0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
The database role to assign to the JIT access

Valid options are "Reader" and "Writer"

Default value is "Reader"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Reader
Accept pipeline input: False
Accept wildcard characters: False
```

### -Reason
The reason for requesting JIT database access

This is logged for audit purposes

Default value is "Administrative access via d365fo.tools"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Administrative access via d365fo.tools
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawOutput
Instructs the cmdlet to include the outer structure of the response received from the endpoint

The output will still be a PSCustomObject

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

### -OutputAsJson
Instructs the cmdlet to convert the output to a Json string

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

## NOTES
Tags: JIT, Database, Access, UDE, OData, RestApi

Author: Mötz Jensen (@Splaxi)

This cmdlet is inspired by the PowerShell script provided in GitHub issue for d365fo.tools

## RELATED LINKS