#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Add Application License info on CPPM

        .DESCRIPTION
        Add Application License (Name/Type and Key)

        .EXAMPLE
        Add-ArubaCPApplicationLicense -product_name Access -license_key XXXXXXX

        Add an Application license type Access with license key XXXXXXX

    #>

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet('Access', 'Access Upgrade', 'Entry', 'Onboard', 'OnGuard', IgnoreCase = $false)]
        [string]$product_name,
        [Parameter (Mandatory = $true)]
        [string]$license_key,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/application-license"

        $_al = New-Object psobject

        $_al | Add-Member -name "product_name" -MemberType NoteProperty -Value $product_name

        $_al | Add-Member -name "license_key" -MemberType NoteProperty -Value $license_key

        $al = Invoke-ArubaCPRestMethod -method "POST" -body $_al -uri $uri -connection $connection
        $al
    }

    End {
    }
}

function Get-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Get Application License info on CPPM

        .DESCRIPTION
        Get Application License (Id, Name, Type, User Count...)

        .EXAMPLE
        Get-ArubaCPApplicationLicense

        Get ALL Application License  on the Clearpass

        .EXAMPLE
        Get-ArubaCPApplicationLicense -id 3001

        Get info about Application License where id equal 3001

        .EXAMPLE
        Get-ArubaCPApplicationLicense -product_name Access

        Get info about Application License where product_name is Access

        .EXAMPLE
        Get-ArubaCPApplicationLicense -license_type Evaluation

        Get info about Application License where license type is Evaluation

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')] #False positive see https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, ParameterSetName = "product_name")]
        [ValidateSet('Access', 'Access Upgrade', 'Entry', 'Onboard', 'OnGuard', IgnoreCase = $false)]
        [string]$product_name,
        [Parameter (Mandatory = $false, ParameterSetName = "license_type")]
        [ValidateSet('Evaluation', 'Permanent', IgnoreCase = $false)]
        [string]$license_type,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/application-license"

        $al = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" { $al._embedded.items | Where-Object { $_.id -eq $id } }
            "product_name" { $al._embedded.items | Where-Object { $_.product_name -eq $product_name } }
            "license_type" { $al._embedded.items | Where-Object { $_.license_type -eq $license_type } }
            default { $al._embedded.items }
        }
    }

    End {
    }
}

function Remove-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Remove an Application License on ClearPass

        .DESCRIPTION
        Remove an Application License) on ClearPass

        .EXAMPLE
        $al = Get-ArubaCPApplicationLicense -product_name Access
        PS C:\>$al | Remove-ArubaCPApplicationLicense

        Remove Application License type Access

        .EXAMPLE
        Remove-ArubaCPApplicationLicense -id 3001 -confirm:$false

        Remove Application License id 3001 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "al")]
        [ValidateScript( { Confirm-ArubaCPApplicationLicense $_ })]
        [psobject]$al,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get Application License id from al ps object
        if ($al) {
            $id = $al.id
            $name = "(" + $al.product_name + ")"
        }

        $uri = "api/application-license/${id}"

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Application License')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}