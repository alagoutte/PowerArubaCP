# PowerArubaCP Tests

## Pre-Requisites

The tests don't be to be run on PRODUCTION ClearPass ! there is no warning about change on ClearPass.
It need to be use only for TESTS !

    A ArubaOS ClearPass with release >= 6.7.x or 6.8.x
    A Token API (See Doc for HOWTO get API)

These are the required modules for the tests

    Pester

## Executing Tests

Assuming you have git cloned the PowerArubaCP repository. Go on tests folder and copy credentials.example.ps1 to credentials.ps1 and edit to set information about your switch (ipaddress, token)

Go after on integration folder and launch all tests via

```powershell
Invoke-Pester *
```

<!--
It is possible to custom some settings when launch test (like vlan id use for vlan test or port used), you need to uncommented following line on credentials.ps1

```powershell
$pester_vlan = XX
$pester_vlanport = XX
...
```
-->

## Executing Individual Tests

Tests are broken up according to functional area. If you are working on NetworkDevice functionality for instance, its possible to just run NetworkDevice related tests.

Example:

```powershell
Invoke-Pester NetworkDevice.Tests.ps1
```

if you only launch a sub test (Describe on pester file), you can use for example to 'Add Network Device' part

```powershell
Invoke-Pester NetworkDevice.Tests.ps1 -g 'Add Network Device'
```

## Known Issues