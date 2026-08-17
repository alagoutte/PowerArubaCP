#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Server Configuration" {

    It "Get ServerConfiguration Does not throw an error" {
        {
            Get-ArubaCPServerConfiguration
        } | Should -Not -Throw
    }

    It "Get Server Configuration (name, uuid, server / management ip... )" {
        $sc = Get-ArubaCPServerConfiguration
        $sc.name | Should -Not -Be $NULL
        $sc.local_server | Should -Not -Be $NULL
        $sc.server_uuid | Should -Not -Be $NULL
        $sc.server_dns_name | Should -Not -Be $NULL
        $sc.management_ip | Should -Not -Be $NULL
        $sc.is_publisher | Should -Not -Be $NULL
        $sc.is_insight_enabled | Should -Not -Be $NULL
        $sc.is_insight_primary | Should -Not -Be $NULL
        $sc.replication_status | Should -Not -Be $NULL
        $sc.is_profiler_enabled | Should -Not -Be $NULL
    }
}


Describe "Get Server Version" {

    It "Get ServerVersion Does not throw an error" {
        {
            Get-ArubaCPServerVersion
        } | Should -Not -Throw
    }

    It "Get Server Version (CPPM, Guest, Installed Patches)" {
        $sv = Get-ArubaCPServerVersion
        $sv.cppm_version | Should -Not -Be $NULL
        $sv.guest_version | Should -Not -Be $NULL
        #No installed patches when it is the first build... (6.10.0...)
        if ($DefaultArubaCPConnection.version.build -ne "0") {
            $sv.installed_patches | Should -Not -Be $NULL
        }
    }
}

Describe "Get CPPM Version" {

    It "Get CPPMVersion Does not throw an error" {
        {
            Get-ArubaCPCPPMVersion
        } | Should -Not -Throw
    }

    It "Get CPPM Version (Major, Minor, service, hardware...)" {
        $cv = Get-ArubaCPCPPMVersion
        $cv.app_major_version | Should -Be "6"
        $cv.app_minor_version | Should -BeIn (8..14)
        $cv.app_service_release | Should -BeIn (0..15)
        $cv.app_build_number | Should -Not -Be $NULL
        $cv.hardware_version | Should -Not -Be $NULL
        $cv.fips_enabled | Should -Not -Be $NULL
        $cv.eval_license | Should -Not -Be $NULL
        $cv.cloud_mode | Should -Not -Be $NULL
    }
}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}