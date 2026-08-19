#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPCertTrustList {

    <#
        .SYNOPSIS
        Add Certificate Trusted List info on CPPM

        .DESCRIPTION
        Add Certificate Trusted List (File, status and Usage)

        .EXAMPLE
        $cert = Get-Content PowerArubaCP.crt -Raw
        Add-ArubaCPCertTrustList -cert_file $cert $cert_usage 'AD/LDAP Servers'

        Add a Certificate Trusted List from cert file PowerAruba.crt with usage AD/LDAP Servers

        .EXAMPLE
        $cert = "-----BEGIN CERTIFICATE----- ..... -----END CERTIFICATE-----"
        Add-ArubaCPCertTrustList -cert_file $cert $cert_usage 'Others' -enabled:$false

        Add a Certificate Trusted List from $cert variable with usage Others and status disable
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$cert_file,
        [Parameter (Mandatory = $false)]
        [switch]$enabled,
        [Parameter (Mandatory = $true)]
        [ValidateSet('AD/LDAP Servers', 'Aruba Infrastructure', 'Aruba Services', 'Database', 'EAP', 'Endpoint Context Servers', 'RadSec', 'SAML', 'SMTP', 'EST', 'Syslog', 'Others', IgnoreCase = $false)]
        [string[]]$cert_usage,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/cert-trust-list"

        $_ctl = New-Object psobject

        $_ctl | Add-Member -name "cert_file" -MemberType NoteProperty -Value $cert_file

        if ( $PsBoundParameters.ContainsKey('enabled') ) {
            if ( $enabled ) {
                $_ctl | add-member -name "enabled" -membertype NoteProperty -Value $true
            }
            else {
                $_ctl | add-member -name "enabled" -membertype NoteProperty -Value $false
            }
        }

        $_ctl | Add-Member -name "cert_usage" -MemberType NoteProperty -Value $cert_usage

        $ctl = Invoke-ArubaCPRestMethod -method "POST" -body $_ctl -uri $uri -connection $connection
        $ctl
    }

    End {
    }
}

function Get-ArubaCPCertTrustList {

    <#
        .SYNOPSIS
        Get Certificate Trusted List on CPPM

        .DESCRIPTION
        Get Certificate Trusted List (Id, file, enabled, Usage ...)

        .EXAMPLE
        Get-ArubaCPCertTrustList

        Get ALL Certificate Trusted Lists on the Clearpass

        .EXAMPLE
        Get-ArubaCPCertTrustList -details

        Get ALL Certificate Trusted Lists with details (subject_DN, issue_date, expiry_date, signature_algorithm...) on the Clearpass

        .EXAMPLE
        Get-ArubaCPCertTrustList -id 23

        Get info about Cert Trust List id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPCertTrustList Aruba -filter_type contains

        Get info about Cert Trust List where cert usage contains Aruba

       .EXAMPLE
        Get-ArubaCPCertTrustList -details -filter_attribute enabled -filter_type equal -filter_value True

        Get info about Cert Trust List details where enabled equal True

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [switch]$details,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "cert_usage")]
        [string]$cert_usage,
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
            "cert_usage" {
                $filter_value = $name
                $filter_attribute = "cert_usage"
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
        if ($details) {
            $uri = "api/cert-trust-list-details"
        }
        else {
            $uri = "api/cert-trust-list"
        }


        $ctl = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection
        $ctl._embedded.items
    }

    End {
    }
}