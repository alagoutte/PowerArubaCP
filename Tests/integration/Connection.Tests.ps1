#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Connect to a ClearPass (using Token)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCP -confirm:$false
    }
    It "Connect to ClearPass (using Token) and check global variable" {
        Connect-ArubaCP @invokeParams
        $DefaultArubaCPConnection | Should -Not -BeNullOrEmpty
        $DefaultArubaCPConnection.server | Should -Be $invokeParams.server
        $DefaultArubaCPConnection.token | Should -Be $invokeParams.token
        $DefaultArubaCPConnection.port | Should -Be $invokeParams.port
    }
    It "Disconnect to ClearPass and check global variable" {
        Disconnect-ArubaCP -confirm:$false
        $DefaultArubaCPConnection | Should -Be $null
    }
    #TODO: Connect using wrong login/password

    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...x
    It "Throw when try to use Connect-ArubaCP with don't use -SkipCertificateCheck" -Skip:("Desktop" -eq $PSEdition) {
        { Connect-ArubaCP $invokeParams.server -Token $invokeParams.token -port $invokeParams.port } | Should -Throw "Unable to connect (certificate)"
        Disconnect-ArubaCP -confirm:$false
    }
    It "Throw when try to use Invoke-ArubaCPRestMethod and not connected" {
        { Invoke-ArubaCPRestMethod -uri "api/cppm-version" } | Should -Throw "Not Connected. Connect to the ClearPass with Connect-ArubaCP"
    }
}

Describe  "Connect to a ClearPass (using multi connection)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCP -confirm:$false
    }

    It "Connect to a ClearPass (using token and store on cppm variable)" {
        $script:cppm = Connect-ArubaCP @invokeParams -DefaultConnection:$false
        $DefaultArubaCPConnection | Should -BeNullOrEmpty
        $cppm.server | Should -Be $invokeParams.server
        $cppm.token | Should -Be $invokeParams.token
        $cppm.port | Should -Be $invokeParams.port
    }

    Context "Use Multi connection for call some (Get) cmdlet (Application Licence, Version, NAS, SHL...)" {
        It "Use Multi connection for call Get Applicetion License " -Skip:$VersionBefore680 {
            { Get-ArubaCPApplicationLicense -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get CPPM Version" {
            { Get-ArubaCPCPPMVersion -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Network Device" {
            { Get-ArubaCPNetworkDevice -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Server Configuration" {
            { Get-ArubaCPServerConfiguration -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Server Version" {
            { Get-ArubaCPServerVersion -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Static Host List" -Skip:$VersionBefore680 {
            { Get-ArubaCPStaticHostList -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Endpoint" {
            { Get-ArubaCPEndpoint -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Api Client" {
            { Get-ArubaCPApiClient -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Service" -Skip:$VersionBefore680 {
            { Get-ArubaCPService -connection $cppm } | Should -Not -Throw
        }
        It "Use Multi connection for call Device Fingerprint" -Skip:$VersionBefore680 {
            $ip = (Get-ArubaCPServerConfiguration -connection $cppm).management_ip
            { Get-ArubaCPDeviceFingerprint -ip_address $ip -connection $cppm } | Should -Not -Throw
        }
    }

    It "Disconnect to a ClearPass (Multi connection)" {
        Disconnect-ArubaCP -connection $cppm -confirm:$false
        $DefaultArubaCPConnection | Should -Be $null
    }

}

Describe "Connect using client_credentials" {
    BeforeAll {
        #connect...
        Connect-ArubaCP @invokeParams
        #Create a API Client with client credentials
        Add-ArubaCPApiClient -client_id pester_PowerArubaCP -client_secret pester_MySecret  -grant_types "client_credentials" -profile_id 1
    }

    It "Connect to a ClearPass (using client_credentials and store on cppm variable)" {
        $script:cppm = Connect-ArubaCP $invokeParams.server -client_id pester_PowerArubaCP -client_secret pester_MySecret -SkipCertificateCheck -port $invokeParams.port -DefaultConnection:$false
        $cppm.server | Should -Be $invokeParams.server
        $cppm.token | Should -Not -BeNullOrEmpty
        $cppm.port | Should -Be $invokeParams.port
    }

    It "Use Multi connection for call Get (Api Client)" {
        { Get-ArubaCPApiClient -connection $cppm } | Should -Not -Throw
    }

    AfterAll {
        #Remove API Client
        Get-ArubaCPApiClient -client_id pester_PowerArubaCP | Remove-ArubaCPApiClient -confirm:$false
        #And disconnect
        Disconnect-ArubaCP -confirm:$false
    }
}

Describe  "Invoke ArubaCP RestMethod tests" {
    BeforeAll {
        #connect...
        Connect-ArubaCP @invokeParams
        #Add 26 Network Device (NAS)
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW4 -ip_address 192.0.2.4 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW5 -ip_address 192.0.2.5 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW6 -ip_address 192.0.2.6 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW7 -ip_address 192.0.2.7 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW8 -ip_address 192.0.2.8 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW9 -ip_address 192.0.2.9 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW10 -ip_address 192.0.2.10 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW11 -ip_address 192.0.2.11 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW12 -ip_address 192.0.2.12 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW13 -ip_address 192.0.2.13 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW14 -ip_address 192.0.2.14 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW15 -ip_address 192.0.2.15 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW16 -ip_address 192.0.2.16 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW17 -ip_address 192.0.2.17 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW18 -ip_address 192.0.2.18 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW19 -ip_address 192.0.2.19 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW20 -ip_address 192.0.2.20 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW21 -ip_address 192.0.2.21 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW22 -ip_address 192.0.2.22 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW23 -ip_address 192.0.2.23 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW24 -ip_address 192.0.2.24 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW25 -ip_address 192.0.2.25 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW26 -ip_address 192.0.2.26 -radius_secret MySecurePassword -vendor Aruba
    }

    It "Use Invoke-ArubaCPRestMethod without limit parameter" {
        #Need to found only less 25 entries...
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device"
        $nad = $response._embedded.items | where-object { $_.name -match "pester_" }
        $nad.count | should -BeLessOrEqual 25
    }

    It "Use Invoke-ArubaCPRestMethod with limit parameter" {
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -limit 1000
        $nad = $response._embedded.items | where-object { $_.name -match "pester_" }
        $nad.count | Should -Be 26
    }

    It "Use Invoke-ArubaCPRestMethod with filter parameter (equal)" {
        #Need to found only pester_SW1
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -filter @{ "name" = "pester_SW1" }
        $nad = $response._embedded.items
        $nad.count | should -BeLessOrEqual 1
    }

    It "Use Invoke-ArubaCPRestMethod with filter parameter (contains)" {
        #Need to found only pester_SW1[X] (11 entries)
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -filter @{ "name" = @{ "`$contains" = "pester_SW1" } }
        $nad = $response._embedded.items
        $nad.count | should -BeLessOrEqual 11
    }

    AfterAll {
        #Remove NAD entries...
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW3 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW4 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW5 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW6 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW7 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW8 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW9 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW10 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW11 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW12 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW13 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW14 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW15 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW16 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW17 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW18 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW19 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW20 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW21 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW22 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW23 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW24 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW25 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW26 | Remove-ArubaCPNetworkDevice -confirm:$false
        #And disconnect
        Disconnect-ArubaCP -confirm:$false
    }
}