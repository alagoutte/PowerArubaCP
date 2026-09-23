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

Disconnect-ArubaCP -confirm:$false