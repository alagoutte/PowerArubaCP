#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

Function Confirm-ArubaCPNetworkDevice {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Network Device (NAS) element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain a id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain an name property."
    }
    if ( -not ( $argument | get-member -name ip_address -Membertype Properties)) {
        throw "Element specified does not contain a ip_address property."
    }
    if ( -not ( $argument | get-member -name radius_secret -Membertype Properties)) {
        throw "Element specified does not contain a radius_secret property."
    }
    if ( -not ( $argument | get-member -name tacacs_secret -Membertype Properties)) {
        throw "Element specified does not contain a tacacs_secret property."
    }
    if ( -not ( $argument | get-member -name vendor_name -Membertype Properties)) {
        throw "Element specified does not contain a vendor_name property."
    }
    if ( -not ( $argument | get-member -name coa_capable -Membertype Properties)) {
        throw "Element specified does not contain a coa_capable property."
    }
    if ( -not ( $argument | get-member -name coa_port -Membertype Properties)) {
        throw "Element specified does not contain a coa_port property."
    }
    $true

}