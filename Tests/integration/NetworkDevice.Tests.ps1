#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Network Device" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
    }

    It "Get NetworkDevice Does not throw an error" {
        {
            Get-ArubaCPNetworkDevice
        } | Should Not Throw
    }

    It "Get ALL Network Device" {
        $nad = Get-ArubaCPNetworkDevice
        $nad.count | Should not be $NULL
    }

    It "Get Network Device (pester_SW1)" {
        $nad = Get-ArubaCPNetworkDevice | Where-Object { $_.name -eq "pester_SW1" }
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW1"
        $nad.description | Should be "Add by PowerArubaCP"
        $nad.ip_address | Should be "192.0.2.1"
        $nad.vendor_name | Should be "Aruba"
        $nad.coa_capable | Should be "False"
        $nad.coa_port | Should be "3799"
    }

    It "Search Network Device by name (pester_SW2)" {
        $nad = Get-ArubaCPNetworkDevice -name pester_SW2
        $nad.count | Should be 1
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW2"
        $nad.description | Should be "Add by PowerArubaCP"
    }

    It "Search Network Device by name ( contains *pester*)" {
        $nad = Get-ArubaCPNetworkDevice -name pester -filter_type contains
        $nad.count | Should be 2
    }

    It "Search Network Device by attribute ( ip_address equal 192.0.2.1 )" {
        $nad = Get-ArubaCPNetworkDevice -filter_attribute ip_address -filter_type equal -filter_value 192.0.2.1
        $nad.count | Should be 1
        $nad.ip_address | Should be "192.0.2.1"
    }
    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -noconfirm
    }
}

Describe  "Add Network Device" {

    It "Add Network Device with Coa Enable and Change Port" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -coa_capable -coa_port 5000
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW1"
        $nad.ip_address | Should be "192.0.2.1"
        $nad.vendor_name | Should be "Aruba"
        $nad.coa_capable | Should be "true"
        $nad.coa_port | Should be "5000"
    }

    It "Add Network Device with TACACS secret (and Cisco vendor)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Cisco -tacacs_secret MySecurePassword
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should not be BeNullOrEmpty
        $nad.name | Should be "pester_SW1"
        $nad.ip_address | Should be "192.0.2.1"
        $nad.vendor_name | Should be "Cisco"
        # radius_secret and tacacs_secret are always empty...
    }

    #Disable... need to check release version and some change with last 6.8 release... need to configure RadSec Settings...
    #It "Add Network Device with RadSec" {
    #    Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -radsec_enabled
    #    $nad = Get-ArubaCPNetworkDevice -name pester_SW1
    #    $nad.id | Should not be BeNullOrEmpty
    #    $nad.name | Should be "pester_SW1"
    #    $nad.ip_address | Should be "192.0.2.1"
    #    $nad.vendor_name | Should be "Aruba"
    #    $nad.radsec_enabled | Should be true
    #}

    AfterEach {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
    }
}

Describe  "Remove Network Device" {

    It "Remove Network Device by id" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.name | Should be "pester_SW1"
        $nad.count | should be 1
        Remove-ArubaCPNetworkDevice -id $nad.id -noconfirm
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad | Should BeNullOrEmpty
        $nad.count | should be 0
    }

    It "Remove Network Device by name (and pipeline)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.name | Should be "pester_SW1"
        $nad.count | should be 1
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad | Should BeNullOrEmpty
        $nad.count | should be 0
    }

    AfterEach {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
    }
}

Disconnect-ArubaCP -noconfirm