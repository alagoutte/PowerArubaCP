#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPEndpoint {

    <#
        .SYNOPSIS
        Add an Endpoint on ClearPass

        .DESCRIPTION
        Add an Endpoint with mac address, description, status, attributes

        .EXAMPLE
        Add-ArubaCPEndpoint -mac_address 000102030405 -description "Add by PowerArubaCP" -Status Known

        Add an Endpoint with MAC Address 000102030405 with Known Status and a description

        .EXAMPLE
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:06 -status Unknown

        Add an Endpoint with MAC Address 00:01:02:03:04:06 with Unknown Status

        .EXAMPLE
        $attributes = @{"Disabled by"="PowerArubaCP"}
        PS >Add-ArubaCPEndpoint -mac_address 000102-030407 -Status Disabled -attributes $attributes

        Add an Endpoint with MAC Address 000102030405 with Disabled Status and attributes to Disabled by PowerArubaCP
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$mac_address,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true)]
        [ValidateSet('Known', 'Unknown', 'Disabled', IgnoreCase = $false)]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/endpoint"

        $_ep = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_ep | add-member -name "id" -membertype NoteProperty -Value $id
        }

        $_ep | add-member -name "mac_address" -membertype NoteProperty -Value (Format-ArubaCPMacAddress $mac_address)

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_ep | add-member -name "description" -membertype NoteProperty -Value $description
        }

        $_ep | add-member -name "status" -membertype NoteProperty -Value $status

        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $_ep | add-member -name "attributes" -membertype NoteProperty -Value $attributes
        }

        $ep = invoke-ArubaCPRestMethod -method "POST" -body $_ep -uri $uri -connection $connection
        $ep
    }

    End {
    }
}

function Get-ArubaCPEndpoint {

    <#
        .SYNOPSIS
        Get Endpoint info on CPPM

        .DESCRIPTION
        Get Endpoint (Id, MAC Address, Status, Attributes)

        .EXAMPLE
        Get-ArubaCPEndpoint

        Get ALL Endpoint on the Clearpass

        .EXAMPLE
        Get-ArubaCPEndpoint 000102030405

        Get info about Endpoint 000102030405 Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPEndpoint -id 23

        Get info about Endpoint id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPEndpoint 000102030405 -filter_type contains

        Get info about Endpoint where name contains 000102

       .EXAMPLE
        Get-ArubaCPEndpoint -filter_attribute attribute -filter_type contains -filter_value 192.0.2.1

        Get info about Endpoint where attribute contains 192.0.2.1
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "mac_address")]
        [string]$mac_address,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "status")]
        [ValidateSet('Known', 'Unknown', 'Disabled')]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "mac_address")]
        [Parameter (ParameterSetName = "status")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter (Mandatory = $false)]
        [int]$limit,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "mac_address" {
                $filter_value = Format-ArubaCPMACAddress $mac_address
                $filter_attribute = "mac_address"
            }
            "status" {
                $filter_value = $status
                $filter_attribute = "status"
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('filter_type') ) {
            switch ( $filter_type ) {
                "equal" {
                    $filter_value = @{ "`$eq" = $filter_value }
                }
                "contains" {
                    $filter_value = @{ "`$contains" = $filter_value }
                }
                default { }
            }
        }

        if ($filter_value -and $filter_attribute) {
            $filter = @{ $filter_attribute = $filter_value }
            $invokeParams.add( 'filter', $filter )
        }

        $uri = "api/endpoint"

        $endpoint = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $endpoint._embedded.items
    }

    End {
    }
}


function Set-ArubaCPEndpoint {

    <#
        .SYNOPSIS
        Configure an Endpoint on ClearPass

        .DESCRIPTION
        Configure an Endpoint on ClearPass

        .EXAMPLE
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        PS C:\>$ep | Set-ArubaCPEndpoint -status Disabled

        Set Status Disabled for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        PS C:\>$ep | Set-ArubaCPEndpoint -description "Change by PowerAruba"

        Change Description for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        PS C:\>$attributes = @{"Disabled by"= "PowerArubaCP"}
        PS C:\>$ep | Set-ArubaCPEndpoint -attributes $attributes

        Change attributes for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        PS C:\>$ep | Set-ArubaCPEndpoint -mac_address 00:01:02:03:04:06

        Change MAC Address 00:01:02:03:04:05 => 00:01:02:03:04:06

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPEndpoint $_ })]
        [psobject]$ep,
        [Parameter (Mandatory = $false)]
        [string]$mac_address,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [ValidateSet('Known', 'Unknown', 'Disabled', IgnoreCase = $false)]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get nad id from nad ps object
        if ($ep) {
            $id = $ep.id
        }

        $uri = "api/endpoint/${id}"
        $_ep = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_ep | add-member -name "id" -membertype NoteProperty -Value $id
        }

        if ( $PsBoundParameters.ContainsKey('mac_address') ) {
            $_ep | add-member -name "mac_address" -membertype NoteProperty -Value $mac_address
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_ep | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('status') ) {
            $_ep | add-member -name "status" -membertype NoteProperty -Value $status
        }

        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $_ep | add-member -name "attributes" -membertype NoteProperty -Value $attributes
        }

        if ($PSCmdlet.ShouldProcess($id, 'Configure Endpoint')) {
            $ep = Invoke-ArubaCPRestMethod -method "PATCH" -body $_ep -uri $uri -connection $connection
            $ep
        }

    }

    End {
    }
}
function Remove-ArubaCPEndpoint {

    <#
        .SYNOPSIS
        Remove an Endpoint on ClearPass

        .DESCRIPTION
        Remove an Endpoint on ClearPass

        .EXAMPLE
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        PS C:\>$ep | Remove-ArubaCPEndpoint

        Remove an Endpoint with MAC Address 00:01:02:03:04:05

        .EXAMPLE
        Remove-ArubaCPEndpoint -id 3001 -confirm:$false

        Remove an Endpoint with id 3001 and no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPEndpoint $_ })]
        [psobject]$ep,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get endpoint id from nad ps object
        if ($ep) {
            $id = $ep.id
            $mac = "(" + $ep.mac_address + ")"
        }

        $uri = "api/endpoint/${id}"

        if ($PSCmdlet.ShouldProcess("$id $mac", 'Remove Endpoint')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }

    }

    End {
    }

}
