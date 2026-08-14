#
# Copyright 2021, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Cluster Certificates (Get-ArubaCPClusterCertificate)" {

    It "Get Cluster Certificates Does not throw an error" {
        {
            Get-ArubaCPClusterCertificate
        } | Should -Not -Throw
    }

    It "Get Cluster Certificates" {
        $cc = Get-ArubaCPClusterCertificate
        @($cc).count | Should -Not -Be $NULL
    }

    It "Get Cluster Certificates and confirm" {
        $cc = Get-ArubaCPClusterCertificate
        Confirm-ArubaCPServerCertificate $cc | Should -Be $true
    }

    It "Get Cluster Certificates with service_id Does not throw an error" {
        {
            Get-ArubaCPClusterCertificate -service_id 1
        } | Should -Not -Throw
    }

    It "Get Cluster Certificates with service_name Does not throw an error" {
        {
            Get-ArubaCPClusterCertificate -service_name "HTTPS(ECC)"
        } | Should -Not -Throw
    }


    It "Get Cluster Certificates with service_type Does not throw an error" {
        {
            Get-ArubaCPClusterCertificate -certificate_type "HTTPS(RSA) Server Certificate"
        } | Should -Not -Throw
    }


    It "Get Cluster Certificates with service_id" {
        $cc = Get-ArubaCPClusterCertificate -service_id 1
        @($cc).count | Should -Not -Be $NULL
    }

    It "Get Cluster Certificates with service_name" {
        $cc = Get-ArubaCPClusterCertificate -service_name "HTTPS(ECC)"
        @($cc).count | Should -Not -Be $NULL
    }


    It "Get Cluster Certificates with service_type" {
        $cc = Get-ArubaCPClusterCertificate -certificate_type "HTTPS(RSA) Server Certificate"
        @($cc).count | Should -Not -Be $NULL
    }


}

Describe  "Get Server Certificate (Get-ArubaCPServerCertificate)" {

    It "Get Server Certificate Does not throw an error" {
        {
            Get-ArubaCPServerCertificate -service_name "RADIUS" -server_uuid $server_uuid
        } | Should -Not -Throw
    }

    It "Get Server Certificate" {
        $cc = Get-ArubaCPServerCertificate -service_name "RadSec" -server_uuid $server_uuid
        @($cc).count | Should -Not -Be $NULL
    }

    It "Get Server Certificate and confirm" {
        $cc = Get-ArubaCPServerCertificate -service_name "HTTPS(RSA)" -server_uuid $server_uuid
        Confirm-ArubaCPServerCertificate $cc | Should -Be $true
    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}