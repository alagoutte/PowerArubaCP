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

    It "Get Cluster Certificates with service_name Does not throw an error" -Skip:$VersionBefore6100 {
        {
            Get-ArubaCPClusterCertificate -service_name "HTTPS(ECC)"
        } | Should -Not -Throw
    }


    It "Get Cluster Certificates with service_type Does not throw an error" -Skip:$VersionBefore6100 {
        {
            Get-ArubaCPClusterCertificate -certificate_type "HTTPS(RSA) Server Certificate"
        } | Should -Not -Throw
    }


    It "Get Cluster Certificates with service_id" {
        $cc = Get-ArubaCPClusterCertificate -service_id 1
        @($cc).count | Should -Not -Be $NULL
    }

    It "Get Cluster Certificates with service_name" -Skip:$VersionBefore6100 {
        $cc = Get-ArubaCPClusterCertificate -service_name "HTTPS(ECC)"
        @($cc).count | Should -Not -Be $NULL
    }


    It "Get Cluster Certificates with service_type" -Skip:$VersionBefore6100 {
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

    It "Get Server Certificate and confirm" -Skip:$VersionBefore6100 {
        $cc = Get-ArubaCPServerCertificate -service_name "HTTPS(RSA)" -server_uuid $server_uuid
        Confirm-ArubaCPServerCertificate $cc | Should -Be $true
    }

}

Describe  "Add Certificate Sign Request (CSR)" {

    It "Add Certificate Sign Request (CSR) with default parameter (RSA 4096 / SHA-512)" {
        $csr = Add-ArubaCPCertSignRequest -common_name MyPowerArubaCP -private_key_password $key_password
        $csr.cert_sign_request | Should -Not -Be $NULL
    }

    It "Add Certificate Sign Request (CSR) with all parameters (org, location, state, Country, san...)" {
        $csr = Add-ArubaCPCertSignRequest -common_name MyPowerArubaCP -organization PowerAruba -organization_unit CP -location Aruba -state PowerAruba -country FR -san DNS:clearpass.example.net -private_key_password $key_password
        $csr.cert_sign_request | Should -Not -Be $NULL
    }

    It "Add Certificate Sign Request (CSR) with other private key type/digest (RSA 2048 / SHA-256)" {
        $csr = Add-ArubaCPCertSignRequest -common_name MyPowerArubaCP -private_key_password $key_password -private_key_type '2048-bit rsa' -digest_algorithm SHA-256
        $csr.cert_sign_request | Should -Not -Be $NULL
    }

    It "Add Certificate Sign Request (CSR) with ECC private key type/digest (ec|secp521r1)" {
        $csr = Add-ArubaCPCertSignRequest -common_name MyPowerArubaCP -private_key_password $key_password -private_key_type 'nist/secg curve over a 521 bit prime field'
        $csr.cert_sign_request | Should -Not -Be $NULL
    }
}

Describe  "Add Self Signed Certificate" {

    Context "Service" {
        It "Add Service Self Signed Certificate (HTTPS RSA) with default parameter (RSA 4096 / SHA-512)" {
            $ssc = Add-ArubaCPSelfSignedCertificate -type "HTTPS(RSA)" -common_name MyPowerArubaCP -private_key_password $key_password
            $ssc.certificate_type | Should -Be "service"
            $ssc.type | Should -Be "HTTPS(RSA) Server Certificate"
            $ssc.subject_CN | Should -Be "MyPowerArubaCP"
            $ssc.private_key_password | Should -Be "mypassword"
            $ssc.private_key_type | Should -Be "4096-bit rsa"
            $ssc.digest_algorithm | Should -Be "SHA-512"
        }

        It "Add Service Self Signed Certificate (HTTPS RSA) with parameter (RSA 2048 / SHA-256)" {
            $ssc = Add-ArubaCPSelfSignedCertificate -type "HTTPS(RSA)" -common_name MyPowerArubaCP -private_key_password $key_password -private_key_type "2048-bit rsa" -digest_algorithm SHA-256
            $ssc.certificate_type | Should -Be "service"
            $ssc.type | Should -Be "HTTPS(RSA) Server Certificate"
            $ssc.subject_CN | Should -Be "MyPowerArubaCP"
            $ssc.private_key_type | Should -Be "2048-bit rsa"
            $ssc.digest_algorithm | Should -Be "SHA-256"
        }

        It "Add Service Self Signed Certificate (HTTPS RSA) with other parameter (org, location, state, Country, san...)" {
            $ssc = Add-ArubaCPSelfSignedCertificate -type "HTTPS(RSA)" -common_name MyPowerArubaCP -private_key_password $key_password -organization PowerAruba -organization_unit CP -location Aruba -state PowerAruba -country FR -san DNS:clearpass.example.net
            $ssc.certificate_type | Should -Be "service"
            $ssc.type | Should -Be "HTTPS(RSA) Server Certificate"
            $ssc.subject_CN | Should -Be "MyPowerArubaCP"
            $ssc.private_key_type | Should -Be "4096-bit rsa"
            $ssc.digest_algorithm | Should -Be "SHA-512"
            $ssc.subject_O | Should -Be "PowerAruba"
            $ssc.subject_OU | Should -Be "CP"
            $ssc.subject_L | Should -Be "Aruba"
            $ssc.subject_C | Should -Be "FR"
            $ssc.subject_SAN | Should -Be "DNS:clearpass.example.net"
        }

        It "Add Service Self Signed Certificate (HTTPS ECC) with parameter (ec|secp521r1 / SHA-384)" {
            $ssc = Add-ArubaCPSelfSignedCertificate -type "HTTPS(ECC)" -common_name MyPowerArubaCP -private_key_password $key_password  -private_key_type 'nist/secg curve over a 521 bit prime field' -digest_algorithm SHA-384
            $ssc.certificate_type | Should -Be "service"
            $ssc.type | Should -Be "HTTPS(ECC) Server Certificate"
            $ssc.subject_CN | Should -Be "MyPowerArubaCP"
            $ssc.private_key_type | Should -Be "nist/secg curve over a 521 bit prime field"
            $ssc.digest_algorithm | Should -Be "SHA-384"
        }
    }

    Context "Server" {

    }

}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}