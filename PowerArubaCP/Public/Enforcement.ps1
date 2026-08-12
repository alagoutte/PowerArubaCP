#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaCPEnforcementPolicy {

    <#
        .SYNOPSIS
        Get Enforcement Policy on CPPM

        .DESCRIPTION
        Get Enforcement Policy (Id, name, description, (enforcement_)type, rules ...)

        .EXAMPLE
        Get-ArubaCPEnforcementPolicy

        Get ALL Enforcement Policies on the Clearpass

        .EXAMPLE
        Get-ArubaCPEnforcementPolicy -id 23

        Get info about Enforcement Policy id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPEnforcementPolicy Aruba -filter_type contains

        Get info about Enforcement Policy where bae contains Aruba

       .EXAMPLE
        Get-ArubaCPEnforcementPolicy -filter_attribute description -filter_type equal -filter_value MAC

        Get info about Enforcement Policies where description equal MAC

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [switch]$details,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$name,
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

        $uri = "api/enforcement-policy"

        $epl = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection
        $epl._embedded.items
    }

    End {
    }
}

function Get-ArubaCPEnforcementProfile {

    <#
        .SYNOPSIS
        Get Enforcement Profile on CPPM

        .DESCRIPTION
        Get Enforcement Profile (Id, name, description, type, attributes ...)

        .EXAMPLE
        Get-ArubaCPEnforcementProfile

        Get ALL Enforcement Profiles on the Clearpass

        .EXAMPLE
        Get-ArubaCPEnforcementProfile -id 23

        Get info about Enforcement Profile id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPEnforcementProfile Aruba -filter_type contains

        Get info about Enforcement Profile where bae contains Aruba

       .EXAMPLE
        Get-ArubaCPEnforcementProfile -filter_attribute description -filter_type equal -filter_value MAC

        Get info about Enforcement Profiles where description equal MAC

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [switch]$details,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$name,
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

        $uri = "api/enforcement-profile"

        $epf = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection
        $epf._embedded.items
    }

    End {
    }
}