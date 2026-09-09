#
# Copyright 2021, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Cert Trust List" {

    It "Get Cert Trust Does not throw an error" {
        {
            Get-ArubaCPCertTrustList
        } | Should -Not -Throw
    }

    It "Get Cert Trust" {
        $ctl = Get-ArubaCPCertTrustList
        @($ctl).count | Should -Not -Be $NULL
    }

    It "Get Cert Trust and confirm" {
        $ctl = Get-ArubaCPCertTrustList
        Confirm-ArubaCPCertTrust $ctl | Should -Be $true
    }

    It "Get Cert Trust with id Does not throw an error" {
        {
            Get-ArubaCPCertTrustList -id 2001
        } | Should -Not -Throw
    }

    It "Get Cert Trust with id" {
        $ctl = Get-ArubaCPCertTrustList -id 2001
        @($ctl).count | Should -Not -Be $NULL
    }

}

Describe "Get Cert Trust List Detail" {

    It "Get Cert Trust Detail Does not throw an error" {
        {
            Get-ArubaCPCertTrustList
        } | Should -Not -Throw
    }

    It "Get Cert Trust Detail" {
        $ctl = Get-ArubaCPCertTrustList
        @($ctl).count | Should -Not -Be $NULL
    }

    It "Get Cert Trust Detail and confirm" {
        $ctl = Get-ArubaCPCertTrustList
        Confirm-ArubaCPCertTrust $ctl | Should -Be $true
    }

    It "Get Cert Trust Detail with id Does not throw an error" {
        {
            Get-ArubaCPCertTrustList -id 2001
        } | Should -Not -Throw
    }

    It "Get Cert Trust Detail with id" {
        $ctl = Get-ArubaCPCertTrustList -id 2001
        @($ctl).count | Should -Not -Be $NULL
    }

}

Describe "Add Cert Trust" {

    It "Add Cert Trust (with cert_usage EAP)" {
        Add-ArubaCPCertTrustList -cert_file $cert_trust -cert_usage EAP
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        $ctl.subject_DN | Should -Not -BeNullOrEmpty
        $ctl.issue_date | Should -Not -BeNullOrEmpty
        $ctl.expiry_date | Should -Not -BeNullOrEmpty
        $ctl.enabled | Should -Be $true
        $ctl.valid | Should -Be "valid"
        $ctl.signature_algorithm | Should -Not -BeNullOrEmpty
        $ctl.public_key_format | Should -Not -BeNullOrEmpty
        $ctl.serial_number | Should -Be $cert_sn
        @($ctl.cert_usage).count | Should -Be 1
        $ctl.cert_usage | Should -BeIn "EAP"
        $ctl.issuer_DN | Should -Not -BeNullOrEmpty
    }

    It "Add Cert Trust (with cert_usage Database, Others)" {
        Add-ArubaCPCertTrustList -cert_file $cert_trust -cert_usage Database, Others
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        $ctl.subject_DN | Should -Not -BeNullOrEmpty
        $ctl.issue_date | Should -Not -BeNullOrEmpty
        $ctl.expiry_date | Should -Not -BeNullOrEmpty
        $ctl.enabled | Should -Be $true
        $ctl.valid | Should -Be "valid"
        $ctl.signature_algorithm | Should -Not -BeNullOrEmpty
        $ctl.public_key_format | Should -Not -BeNullOrEmpty
        $ctl.serial_number | Should -Be $cert_sn
        @($ctl.cert_usage).count | Should -Be 2
        $ctl.cert_usage | Should -BeIn "Others", "Database"
        $ctl.issuer_DN | Should -Not -BeNullOrEmpty
    }

    It "Add Cert Trust (with cert_usage RadSec and status disable)" {
        Add-ArubaCPCertTrustList -cert_file $cert_trust -cert_usage RadSec -enabled:$false
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        $ctl.subject_DN | Should -Not -BeNullOrEmpty
        $ctl.issue_date | Should -Not -BeNullOrEmpty
        $ctl.expiry_date | Should -Not -BeNullOrEmpty
        $ctl.enabled | Should -Be $false
        $ctl.valid | Should -Be "valid"
        $ctl.signature_algorithm | Should -Not -BeNullOrEmpty
        $ctl.public_key_format | Should -Not -BeNullOrEmpty
        $ctl.serial_number | Should -Be $cert_sn
        @($ctl.cert_usage).count | Should -Be 1
        $ctl.cert_usage | Should -BeIn "RadSec"
        $ctl.issuer_DN | Should -Not -BeNullOrEmpty
    }

    AfterEach {
        Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn } | Remove-ArubaCPCertTrustList -confirm:$false
    }

}

Describe "Set Cert Trust" {

    BeforeAll {
        Add-ArubaCPCertTrustList -cert_file $cert_trust -cert_usage EAP
    }

    It "Set Cert Trust status disable" {
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Set-ArubaCPCertTrustList -enabled:$false
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        $ctl.enabled | Should -Be $false
    }

    It "Set Cert Trust status enabled" {
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Set-ArubaCPCertTrustList -enabled
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        $ctl.enabled | Should -Be $true
    }

    It "Set Cert Trust cert usage (Others)" {
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Set-ArubaCPCertTrustList -cert_usage Others
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        @($ctl.cert_usage).count | Should -Be 1
        $ctl.cert_usage | Should -BeIn "Others"
    }

    It "Set Cert Trust cert usage (EAP, Database)" {
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Set-ArubaCPCertTrustList -cert_usage EAP, Database
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        @($ctl.cert_usage).count | Should -Be 2
        $ctl.cert_usage | Should -BeIn "EAP", "Database"
    }

    It "Set Cert Trust (All) cert usage " {
        #All except Syslog..., need CPPM 6.14.x !
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Set-ArubaCPCertTrustList -cert_usage 'AD/LDAP Servers', 'Aruba Infrastructure', 'Aruba Services', 'Database', 'EAP', 'Endpoint Context Servers', 'RadSec', 'SAML', 'SMTP', 'EST', 'Others'
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.id | Should -Not -BeNullOrEmpty
        @($ctl.cert_usage).count | Should -Be 11
        $ctl.cert_usage | Should -BeIn 'AD/LDAP Servers', 'Aruba Infrastructure', 'Aruba Services', 'Database', 'EAP', 'Endpoint Context Servers', 'RadSec', 'SAML', 'SMTP', 'EST', 'Others'
    }

    AfterAll {
        Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn } | Remove-ArubaCPCertTrustList -confirm:$false
    }

}

Describe "Remove Cert Trust" {

    BeforeEach {
        Add-ArubaCPCertTrustList -cert_file $cert_trust -cert_usage EAP
    }

    It "Remove Cert Trust by id" {
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.serial_number | Should -Be $cert_sn
        @($ctl).count | Should -Be 1
        Remove-ArubaCPCertTrustList -id $ctl.id -confirm:$false
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Should -BeNullOrEmpty
        @($ctl).count | Should -Be 0
    }

    It "Remove Endpoint by pipeline" {

        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl.serial_number | Should -Be $cert_sn
        @($ctl).count | Should -Be 1
        $ctl | Remove-ArubaCPCertTrustList -confirm:$false
        $ctl = Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn }
        $ctl | Should -BeNullOrEmpty
        @($ctl).count | Should -Be 0

    }

    AfterEach {
        Get-ArubaCPCertTrustList -details -limit 1000 | Where-Object { $_.serial_number -eq $cert_sn } | Remove-ArubaCPCertTrustList -confirm:$false
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}