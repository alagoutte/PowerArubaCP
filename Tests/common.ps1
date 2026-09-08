#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
Param()

if ("Desktop" -eq $PSVersionTable.PsEdition) {
    # -BeOfType is not same on PowerShell Core and Desktop (get int with Desktop and long with Core for number)
    $script:pester_longint = "int"
}
else {
    $script:pester_longint = "long"
}

. ../credential.ps1
$script:invokeParams = @{
    server               = $ipaddress;
    token                = $token;
    port                 = $port;
    SkipCertificateCheck = $true;
}

if ($null -eq $port) {
    $invokeParams.port = 443
}

#TODO: Add check if no ipaddress/token info...
Connect-ArubaCP @invokeParams
$script:MySecurePassword = ConvertTo-SecureString MyPassword -AsPlainText -Force
$script:MyNewSecurePassword = ConvertTo-SecureString MyNewassword -AsPlainText -Force
$script:key_password = ConvertTo-SecureString mypassword -AsPlainText -Force

$script:VersionBefore680 = $DefaultArubaCPConnection.Version -lt [version]"6.8.0"
$script:VersionBefore686 = $DefaultArubaCPConnection.Version -lt [version]"6.8.6"
$script:VersionBefore690 = $DefaultArubaCPConnection.Version -lt [version]"6.9.0"
$script:VersionBefore6100 = $DefaultArubaCPConnection.Version -lt [version]"6.10.0"
$script:VersionBefore6110 = $DefaultArubaCPConnection.Version -lt [version]"6.11.0"

$script:server_uuid = (Get-ArubaCPServerConfiguration)[0].server_uuid

$script:cert_trust = "
-----BEGIN CERTIFICATE-----
MIIDqzCCApOgAwIBAgIUF8oXC8w+eJzDrsLuQAus6odntNMwDQYJKoZIhvcNAQEL
BQAwcDELMAkGA1UEBhMCRlIxDjAMBgNVBAgMBUFydWJhMQ4wDAYDVQQHDAVBcnVi
YTETMBEGA1UECgwKUG93ZXJBcnViYTEVMBMGA1UECwwMUG93ZXJBcnViYUNQMRUw
EwYDVQQDDAxQb3dlckFydWJhQ1AwHhcNMjYwODE5MDg0ODQ4WhcNNDEwODE5MDg0
ODQ4WjBwMQswCQYDVQQGEwJGUjEOMAwGA1UECAwFQXJ1YmExDjAMBgNVBAcMBUFy
dWJhMRMwEQYDVQQKDApQb3dlckFydWJhMRUwEwYDVQQLDAxQb3dlckFydWJhQ1Ax
FTATBgNVBAMMDFBvd2VyQXJ1YmFDUDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAK/g4J9SvrcKL/kLO+Gogr8EMBIalRIutxCFVFerrKX9guVgeIYUU63J
viHSfQg2WlRDvG/9s+vkmnkT90ni6zYwQXQsT73JrwTJWwGKzp8h28INS1lsT95E
nFZM1gE7jck3kmUtfzq90i/Mv2I6jjuC88Axvd0hSDvgD6BTzlop/JiTqJVpucU2
50ir2ITJAiDJ9vPLYgJOFShPXzWhN6Cg3DqJQ8pXsVcoRUF/rbqw0nba0iQ4Bn8R
rZ9eH1oDPJZxzfPc5Ua53/UyhoTWx5MlhBDz1zk0idf9uffhIqjcT1mFjwn3D6Ku
+u+V66To3+T2+kG90/4ZSXjslFP3rPkCAwEAAaM9MDswFwYDVR0RBBAwDoIMUG93
ZXJBcnViYUNQMAsGA1UdDwQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDATANBgkq
hkiG9w0BAQsFAAOCAQEAELXSCPW70znERH9uz4h2XH+J/M3uixwsdM4A2SgBQpag
B4p9UKv5MxGjhQzoIi/ZMf1H9BV7KeZn4Tbnsnshi5u2IUOA+FGDhM/S++3nFrEA
XRln/OR24XxnJIVJ+aNw/MSzfsxuzv6bXnMiHTrjE2lL5KmNYXj/yEoSvGTpHWyc
h+ToaGHqAnF0eMN64QfLpVCj5QWO2Y5951wi5sZcRajqxS3q2jUFW8tV5WTgQUOW
1ykrTCk9rjlxnk5oiUu81NYbkCYcNQNjyMr2N0ckdgVn6tfmqRc2ltPDIlwFWwcp
YNX3n9Vu069dr5k7aC156DEBmrDho9Oviif5BWP3CQ==
-----END CERTIFICATE-----
"
$script:cert_sn = "135813545856220841402607133080083803402953798867"
Disconnect-ArubaCP -confirm:$false