#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPSelfSignedCertificate {

    <#
        .SYNOPSIS
        Add a Self Signed Certificate on ClearPass

        .DESCRIPTION
        Add a Self Signed Certificate (Service) on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        $key_password = ConvertTo-SecureString mypassword -AsPlainText -Force
        PS > Add-ArubaCPSelfSignedCertificate -certificate_type SERVICE -type HTTPS(RSA) -common_name MyPowerArubaCP -private_key_password $key_password

        Add Self Signed Certificate for service HTTPS (RSA) on SERVICE with Common Name MyPowerArubaCP (with default other settings)

        .EXAMPLE
        $key_password = ConvertTo-SecureString mypassword -AsPlainText -Force
        PS > Add-ArubaCPSelfSignedCertificate -certificate_type SERVICE -type RADIUS -common_name MyPowerArubaCP -organization PowerAruba -organization_unit CP -location Aruba -state PowerAruba -country FR -san DNS:clearpass.example.net -private_key_password $key_password -private_key_type '2048-bit rsa' -digest_algorithm SHA-256

        Add Self Signed Certificate for service RADIUS on service with custom certificate settings (CN, Organization, State...) and RSA 2048 with SHA-256 for cipher/digest algorithm

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("SERVICE")]
        [string]$certificate_type,
        [Parameter (Mandatory = $true)]
        [ValidateSet("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec", "Database")]
        [string]$type,
        [Parameter (Mandatory = $true)]
        [string]$common_name,
        [Parameter (Mandatory = $false)]
        [string]$organization,
        [Parameter (Mandatory = $false)]
        [string]$organization_unit,
        [Parameter (Mandatory = $false)]
        [string]$location,
        [Parameter (Mandatory = $false)]
        [string]$state,
        [Parameter (Mandatory = $false)]
        [string]$country,
        [Parameter (Mandatory = $false)]
        [string]$san,
        [Parameter (Mandatory = $true)]
        [securestring]$private_key_password,
        [Parameter (Mandatory = $false)]
        [ValidateSet('2048-bit rsa', '3072-bit rsa', '4096-bit rsa')]
        [string]$private_key_type = "4096-bit rsa",
        [Parameter (Mandatory = $false)]
        [ValidateSet('SHA-1', 'SHA-224', 'SHA-256', 'SHA-384', 'SHA-512')]
        [string]$digest_algorithm = "SHA-512",
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $uri = "api/self-signed-cert"

        $_ssc = New-Object psobject

        $_ssc | Add-Member -name "certificate_type" -MemberType NoteProperty -Value $certificate_type

        $_ssc | Add-Member -name "type" -MemberType NoteProperty -Value $type

        $_ssc | Add-Member -name "subject_CN" -MemberType NoteProperty -Value $common_name

        if ( $PsBoundParameters.ContainsKey('organization') ) {
            $_ssc | Add-Member -name "subject_O" -MemberType NoteProperty -Value $organization
        }

        if ( $PsBoundParameters.ContainsKey('organization_unit') ) {
            $_ssc | Add-Member -name "subject_OU" -MemberType NoteProperty -Value $organization_unit
        }

        if ( $PsBoundParameters.ContainsKey('location') ) {
            $_ssc | Add-Member -name "subject_L" -MemberType NoteProperty -Value $location
        }

        if ( $PsBoundParameters.ContainsKey('state') ) {
            $_ssc | Add-Member -name "subject_S" -MemberType NoteProperty -Value $state
        }

        if ( $PsBoundParameters.ContainsKey('country') ) {
            $_ssc | Add-Member -name "subject_C" -MemberType NoteProperty -Value $country
        }

        if ( $PsBoundParameters.ContainsKey('san') ) {
            $_ssc | Add-Member -name "subject_SAN" -MemberType NoteProperty -Value $san
        }

        if (("Desktop" -eq $PSVersionTable.PsEdition) -or ($null -eq $PSVersionTable.PsEdition)) {
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($private_key_password);
            $key_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
        }
        else {
            $key_password = ConvertFrom-SecureString -SecureString $private_key_password -AsPlainText
        }

        $_ssc | Add-Member -name "private_key_password" -MemberType NoteProperty -Value $key_password

        $_ssc | Add-Member -name "private_key_type" -MemberType NoteProperty -Value $private_key_type

        $_ssc | Add-Member -name "digest_algorithm" -MemberType NoteProperty -Value $digest_algorithm

        $ssc = Invoke-ArubaCPRestMethod -method "POST" -uri $uri -body $_ssc -connection $connection

        $ssc
    }

    End {
    }
}


function Add-ArubaCPServerCertificate {

    <#
        .SYNOPSIS
        Add a server certificate on ClearPass

        .DESCRIPTION
        Add a server certificate on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        $passphrase = ConvertTo-SecureString mypassword -AsPlainText -Force
        PS > $server_uuid = (Get-ArubaCPServerConfiguration).server_uuid[0]
        PS > Add-ArubaCPServerCertificate -service_name RADIUS -server_uuid server_uuid -pkcs12_file_url http://192.0.2.1/PowerArubaCP.pfx -pkcs12_passphrase $passphrase

        Add certificate (pfx) for service RADIUS on CPPM Server with uuid from Get-ArubaCPServerConfiguration using passphrase
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec", "Database")]
        [string]$service_name,
        [Parameter (Mandatory = $true)]
        [string]$server_uuid,
        [Parameter (Mandatory = $true)]
        [string]$pkcs12_file_url,
        [Parameter (Mandatory = $true)]
        [securestring]$pkcs12_passphrase,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $uri = "api/server-cert/name/${server_uuid}/${service_name}"

        $_cert = New-Object psobject

        $_cert | Add-Member -name "pkcs12_file_url" -MemberType NoteProperty -Value $pkcs12_file_url

        if (("Desktop" -eq $PSVersionTable.PsEdition) -or ($null -eq $PSVersionTable.PsEdition)) {
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pkcs12_passphrase);
            $passphrase = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
        }
        else {
            $passphrase = ConvertFrom-SecureString -SecureString $pkcs12_passphrase -AsPlainText
        }

        $_cert | Add-Member -name "pkcs12_passphrase" -MemberType NoteProperty -Value $passphrase

        $cert = Invoke-ArubaCPRestMethod -method "PUT" -uri $uri -body $_cert -connection $connection

        $cert
    }

    End {
    }
}

function Get-ArubaCPClusterCertificate {

    <#
        .SYNOPSIS
        Get all the cluster certificates on ClearPass

        .DESCRIPTION
        Get all the cluster certificates on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        Get-ArubaCPClusterCertificate

        Return a list of cluster certificates on ClearPass

        .EXAMPLE
        Get-ArubaCPClusterCertificate -service_id 1

        Return the cluster certificate for service id 1 (RADIUS)

        .EXAMPLE
        Get-ArubaCPClusterCertificate -service_name "HTTPS"

        Return the cluster certificate for service name HTTPS

        .EXAMPLE
        Get-ArubaCPClusterCertificate -certificate_type "RadSec Server Certificate"

        Return the cluster certificate which is a RadSec Server Certificate type
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [ValidateSet (1, 2, 7, 21, 106)]
        [int]$service_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "name")]
        [ValidateSet ("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec", "Database")]
        [string]$service_name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "type")]
        [string]$certificate_type,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $uri = "api/server-cert"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" { $cert._embedded.items | Where-Object { $_.service_id -eq $service_id } }
            "name" { $cert._embedded.items | Where-Object { $_.service_name -like $service_name } }
            "type" { $cert._embedded.items | Where-Object { $_.certificate_type -eq $certificate_type } }
            default { $cert._embedded.items }
        }
    }

    End {
    }
}

function Get-ArubaCPServerCertificate {

    <#
        .SYNOPSIS
        Get a server certificate on ClearPass

        .DESCRIPTION
        Get a server certificate on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        $server_uuid = (Get-ArubaCPServerConfiguration).server_uuid[0]
        Get-ArubaCPServerCertificate -service_name RADIUS -server_uuid server_uuid

        Return the RADIUS certificates of first Server (using uuid)
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec", "Database")]
        [string]$service_name,
        [Parameter (Mandatory = $true)]
        [string]$server_uuid,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $uri = "api/server-cert/name/${server_uuid}/${service_name}"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $cert
    }

    End {
    }
}

function Get-ArubaCPServiceCertificate {

    <#
        .SYNOPSIS
        Get Service Certificate on CPPM

        .DESCRIPTION
        Get Service Certificate (Id, file, Usage ...)

        .EXAMPLE
        Get-ArubaCPServiceCertificate

        Get ALL Service Certificates on the Clearpass

        .EXAMPLE
        Get-ArubaCPServiceCertificate -id 23

        Get info about Service Certificate id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPServiceCertificate Aruba -filter_type contains

        Get info about Service Certificate where subject contains Aruba

       .EXAMPLE
        Get-ArubaCPServiceCertificate -filter_attribute validity -filter_type equal -filter_value Valid

        Get info about Service Certificates where validity equal Valid

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [switch]$details,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "subject")]
        [string]$subject,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "subject")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter (Mandatory = $false)]
        [int]$limit,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "subject" {
                $filter_value = $subject
                $filter_attribute = "subject"
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('filter_type') ) {
            switch ( $filter_type ) {
                "equal" {
                    $filter_value = @{ "`$eq" = $filter_value }
                }
                "contains" {
                    $filter_value = @{ "`$contains" = $filter_value }
                }
                default { }
            }
        }

        if ($filter_value -and $filter_attribute) {
            $filter = @{ $filter_attribute = $filter_value }
            $invokeParams.add( 'filter', $filter )
        }

        $uri = "api/service-cert"

        $service_cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection
        $service_cert._embedded.items
    }

    End {
    }
}