#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaCPDeviceFingerprint {

    <#
        .SYNOPSIS
        Get Device Fingerprint info on CPPM

        .DESCRIPTION
        Get Device Fingerprint (hostname, ip, device category/name/family)

        .EXAMPLE
        Get-ArubaCPDeviceFingerprint -mac_adress 000102030405

        Get Device FingerPrint about Endpoint 000102030405 Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPDeviceFingerprint -ip_address 192.0.2.1

        Get Device FingerPrint about Endpoint 192.0.2.1 Aruba on the ClearPass

    #>

    Param(
        [Parameter (ParameterSetName = "mac_address", Mandatory = $true)]
        [string]$mac_address,
        [Parameter (ParameterSetName = "ip_address", Mandatory = $true)]
        [IPAddress]$ip_address,
        [Parameter (Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        $uri = "api/device-profiler/device-fingerprint/"

        switch ( $PSCmdlet.ParameterSetName ) {
            "mac_address" {
                $uri += $mac_address
            }
            "ip_address" {
                $uri += $ip_address.ToString()
            }
            default { }
        }

        $dfp = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $dfp
    }

    End {
    }
}