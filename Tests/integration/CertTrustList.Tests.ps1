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

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}