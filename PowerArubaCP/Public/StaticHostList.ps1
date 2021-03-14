#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Add a Static Host List on ClearPass

        .DESCRIPTION
        Add a Static Host List with Id, Name, description, host format/type ....

        .EXAMPLE
        Add-ArubaCPStaticHostList -name SHL-list-IPAddress -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type IP Address (192.0.2.1....)

        .EXAMPLE
        Add-ArubaCPStaticHostList -name SHL-list-MACAddress -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type MAC Address (00:01:02:03:04:05....)
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true)]
        #[ValidateSet("subnet", "regex", "list")]
        [ValidateSet("list", IgnoreCase = $false)]
        [string]$host_format,
        [Parameter (Mandatory = $false)]
        [ValidateSet("IPAddress", "MACAddress", IgnoreCase = $false)]
        [string]$host_type,
        #[Parameter (Mandatory = $false)]
        #[string]$value,
        #[Parameter (Mandatory = $false)]
        #[psobject]$host_entries,
        [Parameter (Mandatory = $false)]
        [string[]]$host_entries_address,
        [Parameter (Mandatory = $false)]
        [string[]]$host_entries_description,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/static-host-list"

        $_shl = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_shl | Add-Member -name "id" -MemberType NoteProperty -Value $id
        }
        $_shl | Add-Member -name "name" -MemberType NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_shl | Add-Member -name "description" -MemberType NoteProperty -Value $description
        }

        $_shl | Add-Member -name "host_format" -MemberType NoteProperty -Value $host_format

        if ( $PsBoundParameters.ContainsKey('host_type') ) {
            $_shl | Add-Member -name "host_type" -MemberType NoteProperty -Value $host_type
        }

        if ( $PsBoundParameters.ContainsKey('host_entries_address') ) {
            $host_entries = @( )
            $i = 0
            foreach ($host_address in $host_entries_address) {
                $host_entry = New-Object -TypeName PSObject
                $host_entry | Add-Member -name "host_address" -MemberType NoteProperty -Value $host_address
                #if there is not description (or the same number of description and address), set description to "Add via PowerArubaCP"
                if ($PsBoundParameters.ContainsKey('host_entries_description') -and $host_entries_description[$i]) {
                    $host_entry | Add-Member -name "host_address_desc" -MemberType NoteProperty -Value $host_entries_description[$i]
                }
                else {
                    $host_entry | Add-Member -name "host_address_desc" -MemberType NoteProperty -Value "Add via PowerArubaCP"
                }
                $host_entries += $host_entry
                $i++
            }
            $_shl | Add-Member -name "host_entries" -MemberType NoteProperty -Value $host_entries
        }

        $shl = Invoke-ArubaCPRestMethod -method "POST" -body $_shl -uri $uri -connection $connection
        $shl
    }

    End {
    }
}

function Add-ArubaCPStaticHostListMember {

    <#
        .SYNOPSIS
        Add a Static Host List Member on ClearPass

        .DESCRIPTION
        Add a Static Host List Member (IPAddress or MACAddress)

        .EXAMPLE
        Get-ArubaCPStaticHostList -name SHL-list-IPAddress | Add-ArubaCPStaticHostListMember -host_entries_address 192.0.2.2 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type IP Address (192.0.2.2....)

        .EXAMPLE
        Get-ArubaCPStaticHostList -name  SHL-list-MACAddress | Add-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:06 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type MAC Address (00:01:02:03:04:06....)
    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPStaticHostList $_ })]
        [psobject]$shl,
        [Parameter (Mandatory = $true)]
        [string[]]$host_entries_address,
        [Parameter (Mandatory = $false)]
        [string[]]$host_entries_description,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $shl.id
        $uri = "api/static-host-list/${id}"

        $_shl = New-Object -TypeName PSObject

        $_shl | Add-Member -name "host_entries" -MemberType NoteProperty -Value @($shl.host_entries)

        $i = 0
        foreach ($host_address in $host_entries_address) {
            $host_entry = New-Object -TypeName PSObject
            $host_entry | Add-Member -name "host_address" -MemberType NoteProperty -Value $host_address
            #if there is not description (or the same number of description and address), set description to "Add via PowerArubaCP"
            if ($PsBoundParameters.ContainsKey('host_entries_description') -and $host_entries_description[$i]) {
                $host_entry | Add-Member -name "host_address_desc" -MemberType NoteProperty -Value $host_entries_description[$i]
            }
            else {
                $host_entry | Add-Member -name "host_address_desc" -MemberType NoteProperty -Value "Add via PowerArubaCP"
            }
            $_shl.host_entries += $host_entry
            $i++
        }

        $shl = Invoke-ArubaCPRestMethod -method "PATCH" -body $_shl -uri $uri -connection $connection
        $shl
    }

    End {
    }
}
function Get-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Get Static Host List info on CPPM

        .DESCRIPTION
        Get Static Host List (Id, Name, description, host format/type ....)

        .EXAMPLE
        Get-ArubaCPStaticHostList

        Get ALL Static Host List on the Clearpass

        .EXAMPLE
        Get-ArubaCPStaticHostList SHL-PowerArubaCP

        Get info about Static Host List named SHL-PowerArubaCP on the ClearPass

        .EXAMPLE
        Get-ArubaCPStaticHostList -id 23

        Get info about Static Host List id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPStaticHostList SHL-PowerArubaCP -filter_type contains

        Get info about Static Host List where name contains SHL-PowerArubaCP

       .EXAMPLE
        Get-ArubaCPStaticHostList -filter_attribute host_format -filter_type equal -filter_value list

        Get info about Static Host List where host_format equal list

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$Name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "name")]
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

        if ($connection.version -lt [version]"6.8.0") {
            throw "Need ClearPass >= 6.8.0 for use this cmdlet"
        }

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "name" {
                $filter_value = $name
                $filter_attribute = "name"
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

        $uri = "api/static-host-list"

        $shl = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection @invokeParams

        $shl._embedded.items
    }

    End {
    }
}

function Set-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Configure a Static Host List on ClearPass

        .DESCRIPTION
        Configure a Static Host List with Id, Name, description, host format/type ....

        .EXAMPLE
        Get-ArubaCPStaticHostList -name My-SHL-list | Set-ArubaCPStaticHostList -name SHL-list-IPAddress -description "Update via PowerArubaCP"

        Change Static Host List name and description

        .EXAMPLE
        $host_entries = @( )
        PS > $host_entries += @{ host_address = "00:01:02:03:04:05"; host_address_desc = "Change via PowerArubaCP" }
        PS > $host_entries += @{ host_address = "00:01:02:03:04:06"; host_address_desc = "Change via PowerArubaCP" }
        PS > Get-ArubaCPStaticHostList -name My-SHL-list | Set-ArubaCPStaticHostList -host_entries $host_entries

        Change Static Host List with $host_entries
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "shl")]
        [ValidateScript( { Confirm-ArubaCPStaticHostList $_ })]
        [psobject]$shl,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [array]$host_entries,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get shl id from shl ps object
        if ($shl) {
            $id = $shl.id
            $old_name = "(" + $shl.name + ")"
        }

        $uri = "api/static-host-list/${id}"

        $_shl = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_shl | Add-Member -name "name" -MemberType NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_shl | Add-Member -name "description" -MemberType NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('host_entries') ) {
            $_shl | Add-Member -name "host_entries" -MemberType NoteProperty -Value $host_entries
        }

        if ($PSCmdlet.ShouldProcess("$id $old_name", 'Configure Static Host List')) {
            $shl = Invoke-ArubaCPRestMethod -method "PATCH" -body $_shl -uri $uri -connection $connection
            $shl
        }
    }

    End {
    }
}

function Remove-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Remove a Static Host List on ClearPass

        .DESCRIPTION
        Remove a Static Host List on ClearPass

        .EXAMPLE
        $shl = Get-ArubaCPStaticHostList -name SHL-PowerArubaCP
        PS C:\>$shl | Remove-ArubaCPStaticHostList

        Remove Network Device named SHL-PowerArubaCP

        .EXAMPLE
        Remove-ArubaCPStaticHostList -id 3001 -confirm:$false

        Remove Static Host List id 3001 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "shl")]
        [ValidateScript( { Confirm-ArubaCPStaticHostList $_ })]
        [psobject]$shl,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get shl id from shl ps object
        if ($shl) {
            $id = $shl.id
            $name = "(" + $shl.name + ")"
        }

        $uri = "api/static-host-list/${id}"

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Static Host List')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}

function Remove-ArubaCPStaticHostListMember {

    <#
        .SYNOPSIS
        Remove a Static Host List Member on ClearPass

        .DESCRIPTION
        Remove a Static Host List Member (IPAddress or MACAddress)

        .EXAMPLE
        Get-ArubaCPStaticHostList -name SHL-list-IPAddress | Remove-ArubaCPStaticHostListMember -host_entries_address 192.0.2.2

        Remove Static Host List with format list and type IP Address (192.0.2.2....)

        .EXAMPLE
        Get-ArubaCPStaticHostLis -name  SHL-list-MACAddress | Remove-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:06

        Remove Static Host List with format list and type MAC Address (00:01:02:03:04:06....)
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPStaticHostList $_ })]
        [psobject]$shl,
        [Parameter (Mandatory = $true)]
        [string[]]$host_entries_address,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $shl.id
        $name = "(" + $shl.name + ")"
        $uri = "api/static-host-list/${id}"

        $_shl = New-Object -TypeName PSObject

        $host_entries = $shl.host_entries
        foreach ($host_address in $host_entries_address) {
            $host_entries = $host_entries | Where-Object { $_.host_address -ne $host_address }
        }

        if ( $host_entries.count -eq 0 ) {
            Throw "You can't remove all entries. Use Remove-ArubaCPStaticHostList to remove Static Host List"
        }

        $_shl | Add-Member -name "host_entries" -MemberType NoteProperty -Value @($host_entries)

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Static Host List Member')) {
            $shl = Invoke-ArubaCPRestMethod -method "PATCH" -body $_shl -uri $uri -connection $connection
            $shl
        }
    }
    End {
    }
}