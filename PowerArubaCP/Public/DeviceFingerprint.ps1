#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPDeviceFingerprint {

    <#
        .SYNOPSIS
        Add an Endpoint on ClearPass

        .DESCRIPTION
        Add an Endoint with mac address, description, status, attributes

        .EXAMPLE
        Add-ArubaCPEndpoint -mac_address 000102030405 -description "Add by PowerArubaCP" -Status Known

        Add an Endpoint with MAC Address 000102030405 with Known Sattus and a description

        .EXAMPLE
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:06 -status Unknown

        Add an Endpoint with MAC Address 00:01:02:03:04:06 with Unknown Status

        .EXAMPLE
        $attributes = @{"Disabled by"="PowerArubaCP"}
        PS >Add-ArubaCPEndpoint -mac_address 000102-030407 -Status Disabled -attributes $attributes

        Add an Endpoint with MAC Address 000102030405 with Disabled Status and attributes to Disabled by PowerArubaCP
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$mac_address,
        [Parameter (Mandatory = $false)]
        [string]$hostname,
        [Parameter (Mandatory = $false)]
        [ipaddress]$ip_address,
        [Parameter (Mandatory = $false)]
        [string]$device_category,
        [Parameter (Mandatory = $false)]
        [string]$device_name,
        [Parameter (Mandatory = $false)]
        [string]$device_family,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/device-profiler/device-fingerprint"

        $_dfp = new-Object -TypeName PSObject


        $_dfp | add-member -name "mac" -membertype NoteProperty -Value (Format-ArubaCPMacAddress $mac_address)

        if ( $PsBoundParameters.ContainsKey('hostname') ) {
            $_dfp | add-member -name "hostname" -membertype NoteProperty -Value $hostname
        }

        if ( $PsBoundParameters.ContainsKey('ip_address') ) {
            $_dfp | add-member -name "ip" -membertype NoteProperty -Value $ip_address.ToString()
        }

        $_device = new-Object -TypeName PSObject
        if ( $PsBoundParameters.ContainsKey('device_category') ) {
            $_device | add-member -name "category" -membertype NoteProperty -Value $device_category
        }

        if ( $PsBoundParameters.ContainsKey('device_name') ) {
            $_device | add-member -name "name" -membertype NoteProperty -Value $device_name
        }

        if ( $PsBoundParameters.ContainsKey('device_family') ) {
            $_device | add-member -name "family" -membertype NoteProperty -Value $device_family
        }

        $_dfp | add-member -name "device" -membertype NoteProperty -Value $_device

        $dfp = Invoke-ArubaCPRestMethod -method "POST" -body $_dfp -uri $uri -connection $connection
        $dfp
    }

    End {
    }
}

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
        Get-ArubaCPEndpoint 000102030405 | Get-ArubaCPDeviceFingerprint

        Get Device FingerPrint using Endpoint 000102030405

        .EXAMPLE
        Get-ArubaCPDeviceFingerprint -ip_address 192.0.2.1

        Get Device FingerPrint about Endpoint 192.0.2.1 Aruba on the ClearPass

    #>

    Param(
        [Parameter (ParameterSetName = "mac_address", Mandatory = $true)]
        [string]$mac_address,
        [Parameter (ParameterSetName = "ip_address", Mandatory = $true)]
        [IPAddress]$ip_address,
        [Parameter (ParameterSetName = "endpoint", Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPEndpoint $_ })]
        [psobject]$endpoint,
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
            "endpoint" {
                $uri += $endpoint.mac_address
            }
            default { }
        }

        $dfp = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $dfp
    }

    End {
    }
}