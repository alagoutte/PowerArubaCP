#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPService {

    <#
        .SYNOPSIS
        Get Service info on CPPM

        .DESCRIPTION
        Get Service (Id, Name, Type, Template ....)

        .EXAMPLE
        Get-ArubaCPService

        Get ALL Service on the Clearpass

        .EXAMPLE
        Get-ArubaCPService SVC-PowerArubaCP

        Get info about Service SVC-PowerArubaCP Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPService -id 23

        Get info about Service id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPService PowerArubaCP -filter_type contains

        Get info about Service where name contains PowerArubaCP

       .EXAMPLE
        Get-ArubaCPService -filter_attribute type -filter_type equal -filter_value RADIUS

        Get info about Service where type equal RADIUS

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$Name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "name")]
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
            "name" {
                $filter_value = $name
                $filter_attribute = "name"
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

        $uri = "api/config/service"

        $cs = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $cs._embedded.items
    }

    End {
    }
}

function Enable-ArubaCPService {

    <#
        .SYNOPSIS
        Enable a Service on ClearPass

        .DESCRIPTION
        Enable a Service on ClearPass

        .EXAMPLE
        Get-ArubaCPService -name PowerArubaCP | Enable-ArubaCPService

        Enable Service PowerArubaCP

        .EXAMPLE
        Get-ArubaCPService -id 1 | Enable-ArubaCPService

        Enable Service with id 1
    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPService $_ })]
        [psobject]$cs,
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $cs.id
        $uri = "api/config/service/${id}/enable"

        $cs = Invoke-ArubaCPRestMethod -method "PATCH" -uri $uri -connection $connection
        $cs
    }

    End {
    }
}

function Disable-ArubaCPService {

    <#
        .SYNOPSIS
        Disable a Service on ClearPass

        .DESCRIPTION
        Disable a Service on ClearPass

        .EXAMPLE
        Get-ArubaCPService -name PowerArubaCP | Disable-ArubaCPService

        Disable Service PowerArubaCP

        .EXAMPLE
        Get-ArubaCPService -id 1 | Disable-ArubaCPService

        Disable Service with id 1
    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPService $_ })]
        [psobject]$cs,
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $cs.id
        $uri = "api/config/service/${id}/disable"

        $cs = Invoke-ArubaCPRestMethod -method "PATCH" -uri $uri -connection $connection
        $cs
    }

    End {
    }
}
