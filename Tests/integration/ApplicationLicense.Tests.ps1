#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Application License" {

    It "Get Application License Does not throw an error" -Skip:$VersionBefore680 {
        {
            Get-ArubaCPApplicationLicense
        } | Should -Not -Throw
    }

    It "Get ALL Application License" -Skip:$VersionBefore680 {
        $al = Get-ArubaCPApplicationLicense
        @($al).count | Should -Not -Be $NULL
    }

    It "Get Application License and confirm" -Skip:$VersionBefore680 {
        $al = Get-ArubaCPApplicationLicense
        Confirm-ArubaCPApplicationLicense $al[0] | Should -Be $true
    }

}

Describe "Add and Remove Application License" {

    It "Add Application License ($pester_license_type)" -Skip:( -not ($pester_license -ne $null -and $VersionBefore680 -eq 0) ) {
        Add-ArubaCPApplicationLicense -product_name $pester_license_type -license_key $pester_license
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type #Only check if search work !
        $al.id | Should -Not -BeNullOrEmpty
        $al.product_name | Should -Be $pester_license_type
    }

    It "Remove Application License ($pester_license_type)" -Skip:( -not ($pester_license -ne $null -and $VersionBefore680 -eq 0)) {
        Get-ArubaCPApplicationLicense -product_name $pester_license_type | Remove-ArubaCPApplicationLicense -confirm:$false
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type
        $al | Should -Be $null
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}