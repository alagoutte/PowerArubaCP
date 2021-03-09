#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe  "Get Device FingerPrint" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPDeviceFingerPrint -mac_address 00-01-02-03-04-05 -ip_address 192.0.2.1
        Add-ArubaCPDeviceFingerPrint -mac_address 00-01-02-03-04-06 -ip_address 192.0.2.2
        #Need to wait the time of profiling... (2 seconds...)
        Start-Sleep 2
    }

    It "Get Endpoint (with mac filter) Does not throw an error" {
        {
            Get-ArubaCPDeviceFingerPrint -mac_address 00-01-02-03-04-05
        } | Should -Not -Throw
    }

    It "Search Device Fingerprint by mac (00-01-02-03-04-05)" {
        $dfp = Get-ArubaCPDeviceFingerprint -mac_address 000102030405
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.mac | Should -Be "000102030405"
        $dfp.device_category | Should -Not -BeNullOrEmpty
        $dfp.device_name | Should -Not -BeNullOrEmpty
        $dfp.device_family | Should -Not -BeNullOrEmpty
    }

    It "Search Device Fingerprint by Endpoint pipeline (00-01-02-03-04-06)" {
        $dfp = Get-ArubaCPEndpoint -mac_address 000102030406 | Get-ArubaCPDeviceFingerprint
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.mac | Should -Be "000102030406"
        $dfp.device_category | Should -Not -BeNullOrEmpty
        $dfp.device_name | Should -Not -BeNullOrEmpty
        $dfp.device_family | Should -Not -BeNullOrEmpty
    }

    It "Search Device Fingerprint by ip_address (192.0.2.2)" {
        $dfp = Get-ArubaCPDeviceFingerprint -ip_address 192.0.2.2
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.ip | Should -Be "192.0.2.2"
        $dfp.device_category | Should -Not -BeNullOrEmpty
        $dfp.device_name | Should -Not -BeNullOrEmpty
        $dfp.device_family | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-05 | Remove-ArubaCPEndpoint -confirm:$false
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-06 | Remove-ArubaCPEndpoint -confirm:$false
    }
}

Describe  "Add Device Fingerprint" {

    It "Add Device Fingerprint with hostname" {
        Add-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-07 -hostname pester_PowerArubaCP
        Start-Sleep 2
        $dfp = Get-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-07
        $dfp.hostname | Should -be "pester_PowerArubaCP"
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.mac | Should -Be "000102030407"
        $dfp.device_category | Should -Not -BeNullOrEmpty
        $dfp.device_name | Should -Not -BeNullOrEmpty
        $dfp.device_family | Should -Not -BeNullOrEmpty
    }

    It "Add Device Fingerprint with IP (Address)" {
        Add-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-08 -ip_address 192.0.2.1
        Start-Sleep 2
        $dfp = Get-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-08
        $dfp.ip | Should -be "192.0.2.1"
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.mac | Should -Be "000102030408"
        $dfp.device_category | Should -Not -BeNullOrEmpty
        $dfp.device_name | Should -Not -BeNullOrEmpty
        $dfp.device_family | Should -Not -BeNullOrEmpty
    }

    It "Add Device Fingerprint with device information" {
        Add-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-09 -device_category Server -device_family ClearPass -device_name ClearPass VM
        Start-Sleep 2
        $dfp = Get-ArubaCPDeviceFingerprint -mac_address 00-01-02-03-04-09
        $dfp.updated_at | Should -Not -BeNullOrEmpty
        $dfp.added_at | Should -Not -BeNullOrEmpty
        $dfp.mac | Should -Be "000102030409"
        $dfp.device_category | Should -Be "Server"
        $dfp.device_name | Should -Be "Clearpass"
        $dfp.device_family | Should -Be "ClearPass"
    }

    AfterAll {
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-07 | Remove-ArubaCPEndpoint -confirm:$false
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-08 | Remove-ArubaCPEndpoint -confirm:$false
        Get-ArubaCPEndpoint -mac_address 00-01-02-03-04-09 | Remove-ArubaCPEndpoint -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}