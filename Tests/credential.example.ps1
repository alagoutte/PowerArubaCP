#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

# Copy this file to credential.ps1 (on Tests folder) and change connection settings..

$script:ipaddress = "10.44.23.213"
$script:token = "aaaaaaaaaaaaaaaaaa"

#Uncomment if you want to use another port to access to ClearPass
#script:port = "443"

#Uncomment if you want to enable add and Remove Application License (recommended to use Onboard license for test...)
#$script:pester_license_type = "Onboard"
#$script:pester_license = "
#-----BEGIN CLEARPASS ONBOARD LICENSE KEY-----
#.....
#-----END CLEARPASS ONBOARD LICENSE KEY-----"