<#
    .SYNOPSIS
        Lists all items that are scheduled to be published, but yet to be published.
    
    .NOTES
        Sitecore
#>

$database = "master"
$root = Get-Item -Path (@{$true="$($database):\content\home"; $false="$($database):\content"}[(Test-Path -Path "$($database):\content\home")])

$settings = @{
    Title = "Report Filter"
    OkButtonName = "Proceed"
    CancelButtonName = "Abort"
    Description = "Filter the results for items that are scheduled to be published, but not yet published"
    Parameters = @(
        @{
            Name="root"; 
            Title="Choose the report root"; 
            Tooltip="Only items from this root will be returned.";
        }
    )
    Icon = [regex]::Replace($PSScript.Appearance.Icon, "Office", "OfficeWhite", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    ShowHint = $true
}

$result = Read-Variable @settings
if($result -ne "ok") {
    Exit
}

filter Where-LastUpdated {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Sitecore.Data.Items.Item]$Item,
        
        [datetime]$Date=([datetime]::Today)
    )
    
    # ValidFrom is the field that Sitecore stores the Schedule publishing from date/time
    $convertedDate = [Sitecore.DateUtil]::IsoDateToDateTime($item.Fields[[Sitecore.FieldIDs]::ValidFrom].Value)

    if($convertedDate -ge $Date) {
        $item
    }
}

function GetTimespan {
  param (
    $item,
    [datetime]$Date=([datetime]::Today)
  )
  
  $validFrom = [Sitecore.DateUtil]::IsoDateToDateTime($item.Fields[[Sitecore.FieldIDs]::ValidFrom].Value)
  $ts = New-TimeSpan -Start $Date -End $validFrom

  $ts.Days.ToString()
}

$items = @($root) + @(($root.Axes.GetDescendants())) | Where-LastUpdated | Initialize-Item

if($items.Count -eq 0) {
    Show-Alert "There are no items scheduled but not yet published"
} else {
    $props = @{
        Title = "Items Scheduled to be Published but not yet Published Report"
        InfoTitle = "Items scheduled"
        InfoDescription = "Lists all items scheduled but not yet published"
        PageSize = 25
    }
    
    $items |
        Show-ListView @props -Property @{Label="Name"; Expression={$_.DisplayName} },
            @{Label="Updated"; Expression={$_.__Updated} },
            @{Label="Updated by"; Expression={$_."__Updated by"} },
            @{Label="Pending Publish date"; Expression={$_."__Valid from"} },
            @{Label="Days remaining until published"; Expression={ GetTimespan $_ } },
            @{Label="Created by"; Expression={$_."__Created by"} },
            @{Label="Path"; Expression={$_.ItemPath} }
}
Close-Window