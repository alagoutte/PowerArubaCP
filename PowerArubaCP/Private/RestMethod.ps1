#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCPRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with ArubaCP connection (internal) variable

      .DESCRIPTION
       Invoke RestMethod with ArubaCP connection variable (token, csrf..)

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "get" -uri "api/cppm-version"

      Invoke-RestMethod with ArubaCP connection for get api/cppm-version

      .EXAMPLE
      Invoke-ArubaCPRestMethod "api/cppm-version"

      Invoke-RestMethod with ArubaCP connection for get api/cppm-version uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "post" -uri "api/cppm-version" -body $body

      Invoke-RestMethod with ArubaCP connection for post api/cppm-version uri with $body payload

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "post" -uri "api/cppm-version" -body $body

      Invoke-RestMethod with ArubaCP connection for post api/cppm-version uri with $body payload

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "get" -uri "api/network-device" -limit 1000

      Invoke-RestMethod with ArubaCP connection for get api/network-device uri with limit to 1000

     .EXAMPLE
      Invoke-ArubaCPRestMethod -method "get" -uri "api/network-device" -filter @{ "name" = "PowerArubaCP" }

      Invoke-RestMethod with ArubaCP connection for get api/network-device uri with filter name equal PowerArubaCP

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "get" -uri "api/network-device" -filter @{ "name" = @{ "`$contains" = "PowerArubaCP" } }

      Invoke-RestMethod with ArubaCP connection for get api/network-device uri with filter name contains PowerArubaCP
    #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE", "PATCH")]
        [String]$method = "GET",
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 1000)]
        [int]$limit,
        [Parameter(Mandatory = $false)]
        [array]$filter
    )

    Begin {
    }

    Process {

        if ($null -eq $DefaultArubaCPConnection) {
            Throw "Not Connected. Connect to the ClearPass with Connect-ArubaCP"
        }

        $Server = ${DefaultArubaCPConnection}.Server
        $invokeParams = ${DefaultArubaCPConnection}.invokeParams
        $port = ${DefaultArubaCPConnection}.port
        $fullurl = "https://${Server}:${port}/${uri}"

        if ($fullurl -NotMatch "\?") {
            $fullurl += "?"
        }

        #Add calculate_count to each get command to get the number of
        if ($method -eq "GET") {
            $fullurl += "&calculate_count=true"
        }
        if ($limit) {
            $fullurl += "&limit=$limit"
        }
        if ($filter) {
            $fullurl += "&filter=$($filter | ConvertTo-Json -Compress)"
        }
        #When headers, We need to have Accept and Content-type set to application/json...
        $headers = @{ Authorization = "Bearer " + $DefaultArubaCPConnection.token; Accept = "application/json"; "Content-type" = "application/json" }

        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers @invokeParams
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers @invokeParams
            }
        }

        catch {
            Show-ArubaCPException $_
            throw "Unable to use ClearPass API"
        }
        #Only if limit is no set and $response._embedded.items(.count) is not empty
        if (-Not $limit -and $response._embedded.items.count) {
            #Check if number a item calculate by CPPM (calculate_count) is superior to return item (and generate a warning about use -limit)
            if ($response.count -gt $response._embedded.items.count) {
                Write-Warning "There is extra items use -limit parameter to display"
            }
        }
        $response

    }

}
