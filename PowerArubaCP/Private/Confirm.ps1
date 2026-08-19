#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

Function Confirm-ArubaCPApiClient {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Api Client element

    if ( -not ( $argument | get-member -name client_id -Membertype Properties)) {
        throw "Element specified does not contain a client_id property."
    }
    if ( -not ( $argument | get-member -name client_secret -Membertype Properties)) {
        throw "Element specified does not contain a client_secret property."
    }
    if ( -not ( $argument | get-member -name grant_types -Membertype Properties)) {
        throw "Element specified does not contain a grant_types property."
    }
    if ( -not ( $argument | get-member -name profile_id -Membertype Properties)) {
        throw "Element specified does not contain a profile_id property."
    }
    $true

}
Function Confirm-ArubaCPApplicationLicense {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Application License element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name product_id -Membertype Properties)) {
        throw "Element specified does not contain a product_id property."
    }
    if ( -not ( $argument | get-member -name product_name -Membertype Properties)) {
        throw "Element specified does not contain a product_name property."
    }
    if ( -not ( $argument | get-member -name license_key -Membertype Properties)) {
        throw "Element specified does not contain a license_key property."
    }
    if ( -not ( $argument | get-member -name license_type -Membertype Properties)) {
        throw "Element specified does not contain a license_type property."
    }
    if ( -not ( $argument | get-member -name user_count -Membertype Properties)) {
        throw "Element specified does not contain an user_count property."
    }
    if ( -not ( $argument | get-member -name license_added_on -Membertype Properties)) {
        throw "Element specified does not contain a license_added_on property."
    }
    if ( -not ( $argument | get-member -name activation_status -Membertype Properties)) {
        throw "Element specified does not contain an activation_status property."
    }
    $true

}

Function Confirm-ArubaCPCertTrust {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Certificate Trust element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name enabled -Membertype Properties)) {
        throw "Element specified does not contain an enabled property."
    }
    if ( -not ( $argument | get-member -name cert_usage -Membertype Properties)) {
        throw "Element specified does not contain a cert_usage property."
    }
    $true

}

Function Confirm-ArubaCPEndpoint {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an EndPoint element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name mac_address -Membertype Properties)) {
        throw "Element specified does not contain a product_id property."
    }
    if ( -not ( $argument | get-member -name status -Membertype Properties)) {
        throw "Element specified does not contain a status property."
    }
    if ( -not ( $argument | get-member -name attributes -Membertype Properties)) {
        throw "Element specified does not contain an attributes property."
    }
    $true

}


function Confirm-ArubaCPLocalUser {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like a Local User (lu) element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name user_id -Membertype Properties)) {
        throw "Element specified does not contain an user_id property."
    }
    if ( -not ( $argument | get-member -name username -Membertype Properties)) {
        throw "Element specified does not contain an username property."
    }
    if ( -not ( $argument | get-member -name role_name -Membertype Properties)) {
        throw "Element specified does not contain a role_name property."
    }
    if ( -not ( $argument | get-member -name change_pwd_next_login -Membertype Properties)) {
        throw "Element specified does not contain a change_pwd_next_login property."
    }
    $true

}

Function Confirm-ArubaCPNetworkDevice {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Network Device (NAS) element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    if ( -not ( $argument | get-member -name ip_address -Membertype Properties)) {
        throw "Element specified does not contain an ip_address property."
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

function Confirm-ArubaCPNetworkDeviceGroup {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Network Device Group (NDG) element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    if ( -not ( $argument | get-member -name group_format -Membertype Properties)) {
        throw "Element specified does not contain a group_format property."
    }
    if ( -not ( $argument | get-member -name value -Membertype Properties)) {
        throw "Element specified does not contain a value property."
    }
    $true

}

Function Confirm-ArubaCPServerCertificate {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Server Certificate element

    if ( -not ( $argument | get-member -name service_id -Membertype Properties)) {
        throw "Element specified does not contain a service_id property."
    }
    if ( -not ( $argument | get-member -name service_name -Membertype Properties)) {
        throw "Element specified does not contain a service_name property."
    }
    if ( -not ( $argument | get-member -name certificate_type -Membertype Properties)) {
        throw "Element specified does not contain a certificate_type property."
    }
    if ( -not ( $argument | get-member -name subject -Membertype Properties)) {
        throw "Element specified does not contain a subject property."
    }
    if ( -not ( $argument | get-member -name expiry_date -Membertype Properties)) {
        throw "Element specified does not contain an expiry_date property."
    }
    if ( -not ( $argument | get-member -name issue_date -Membertype Properties)) {
        throw "Element specified does not contain an issue_date property."
    }
    if ( -not ( $argument | get-member -name issued_by -Membertype Properties)) {
        throw "Element specified does not contain an issued_by property."
    }
    if ( -not ( $argument | get-member -name validity -Membertype Properties)) {
        throw "Element specified does not contain a validity property."
    }
    if ( -not ( $argument | get-member -name root_ca_cert -Membertype Properties)) {
        throw "Element specified does not contain a root_ca_cert property."
    }
    if ( -not ( $argument | get-member -name intermediate_ca_cert -Membertype Properties)) {
        throw "Element specified does not contain an intermediate_ca_cert property."
    }
    if ( -not ( $argument | get-member -name cert_file -Membertype Properties)) {
        throw "Element specified does not contain a cert_file property."
    }
    if ( -not ( $argument | get-member -name enabled -Membertype Properties)) {
        throw "Element specified does not contain a enabled property."
    }
    $true

}
Function Confirm-ArubaCPRole {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like a Role element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    #if ( -not ( $argument | get-member -name description -Membertype Properties)) {
    #    throw "Element specified does not contain a description property."
    #}
    $true

}

Function Confirm-ArubaCPService {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Service element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    if ( -not ( $argument | get-member -name type -Membertype Properties)) {
        throw "Element specified does not contain a type property."
    }
    if ( -not ( $argument | get-member -name template -Membertype Properties)) {
        throw "Element specified does not contain a template property."
    }
    if ( -not ( $argument | get-member -name enabled -Membertype Properties)) {
        throw "Element specified does not contain an enabled property."
    }
    # orderNo is now order_no with CPPM 6.10.x
    #if ( -not ( $argument | get-member -name orderNo -Membertype Properties)) {
    #    throw "Element specified does not contain an orderNo property."
    #}
    $true

}

Function Confirm-ArubaCPStaticHostList {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Static Host List element

    if ( -not ( $argument | get-member -name id -Membertype Properties)) {
        throw "Element specified does not contain an id property."
    }
    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    if ( -not ( $argument | get-member -name host_format -Membertype Properties)) {
        throw "Element specified does not contain a host_format property."
    }
    if ( -not ( $argument | get-member -name host_type -Membertype Properties)) {
        throw "Element specified does not contain a host_type property."
    }
    $true

}