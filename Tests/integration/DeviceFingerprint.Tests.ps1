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

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}