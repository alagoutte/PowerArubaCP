#
# Copyright 2018-2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Service" {

    It "Get Service Does not throw an error" {
        {
            Get-ArubaCPService
        } | Should -Not -Throw
    }

    It "Get Service" {
        $s = Get-ArubaCPService
        $s.count | Should -Not -Be $NULL
    }

    It "Get Service id (id 1)" {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        $s.id | Should -Be "1"
        $s.name | Should -Be "[Policy Manager Admin Network Login Service]"
        $s.type | Should -Be "TACACS"
        $s.template | Should -Be "TACACS+ Enforcement"
        $s.enabled | Should -Be "True"
        $s.order_No | Should -Be "1"
    }

    It "Get Service (id 1) and confirm (via Confirm-ArubaCPService)" {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        Confirm-ArubaCPService $s | Should -Be $true
    }

    It "Search Service by id (1)" {
        $s = Get-ArubaCPService -id 1
        @($s).count | Should -Be 1
        $s.id | Should -Not -BeNullOrEmpty
        $s.name | Should -Be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Service by name ([Policy Manager Admin Network Login Service])" {
        $s = Get-ArubaCPService -name '[Policy Manager Admin Network Login Service]'
        @($s).count | Should -Be 1
        $s.id | Should -Not -BeNullOrEmpty
        $s.name | Should -Be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Service by name (contains *Policy*)" {
        $s = Get-ArubaCPService -name Policy -filter_type contains
        @($s).count | Should -Be 1
        $s.id | Should -Not -BeNullOrEmpty
        $s.name | Should -Be "[Policy Manager Admin Network Login Service]"
    }

    #Warning freeze because 6.8.6...
    It "Search Service by attribute (type equal RADIUS)" {
        $s = Get-ArubaCPService -filter_attribute type -filter_type equal -filter_value RADIUS
        @($s).count | Should -Be 1
        $s.type | Should -be "RADIUS"
    }

}

Describe "Enable / Disable Service" {

    It "Disable Service (id 1)" {
        $s = Get-ArubaCPService -id 1
        $s.enabled | Should -Be "True"
        $s = Get-ArubaCPService -id 1 | Disable-ArubaCPService
        $s.enabled | Should -Be "false"
    }

    It "Enable Service (id 1)" {
        $s = Get-ArubaCPService -id 1 | Enable-ArubaCPService
        $s.enabled | Should -Be "true"
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}