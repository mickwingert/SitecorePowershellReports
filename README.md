# Sitecore Powershell Reports Extensions

Additional reports based on Sitecore Powershell Extensions

## Dependency

These additional reports require [Sitecore Powershell Extensions](https://doc.sitecorepowershell.com/) to be installed prior to utilising this package.

[Download](https://marketplace.sitecore.net/Modules/Sitecore_PowerShell_console.aspx) the module from the Sitecore Marketplace and install through the Installation Wizard.

## Installation Instructions

The Powershell code can be installed by manually creating new 'Powershell Script' underneath the `/sitecore/system/Modules/PowerShell/Script Library/SPE/Reporting/Content Reports/Reports/Content Audit item`

Alternatively, a Sitecore installation package is provided within the source code under the `packages` folder.

## Reports

### Inactive items in x days report

This report returns Sitecore items that have not been updated within a specified time period. The user can select from 30, 60, 90 and 120 days by default. 

### Items schedule but not yet published

This report outlines Sitecore items that have a publishing schedule defined with a future publish date. The report will show the schedule publish date, and the number of days remaining until publish.