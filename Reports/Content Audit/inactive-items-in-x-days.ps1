<#
    .SYNOPSIS
        Lists all items not updated within a given time period.
    
    .NOTES
        Sitecore
#>

$database = "master"
$root = Get-Item -Path (@{$true="$($database):\content\home"; $false="$($database):\content"}[(Test-Path -Path "$($database):\content\home")])
$maxDaysOptions = [ordered]@{"-- Skip --"=[int]::MaxValue;30=30;90=90;120=120;365=365;}

$settings = @{
    Title = "Report Filter"
    OkButtonName = "Proceed"
    CancelButtonName = "Abort"
    Description = "Filter the results for items that haven't been updated within a specific time frame"
    Parameters = @(
        @{
            Name="root"; 
            Title="Choose the report root"; 
            Tooltip="Only items from this root will be returned.";
        },
        @{
            Name = "selectedMaxDays"
            Title = "Max Days"
            Value = [int]::MaxValue
            Options = $maxDaysOptions
            Tooltip = "Pick the maximum number of days to include as the range"
            Editor = "combo"
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
        
        [datetime]$Date=([datetime]::Today),
        
        [int]$MaxDays
    )
    
    $itemLastUpdatedDate = [Sitecore.DateUtil]::IsoDateToDateTime($item.Fields[[Sitecore.FieldIDs]::Updated].Value)
    $isWithinDate = $false

    if($itemLastUpdatedDate -le $Date) {
        $isWithinDate = $true
    }
    
    if($isWithinDate) {
        if($MaxDays -lt [int]::MaxValue) {

            # Get the timespan difference between last updated of the SC item and the current date
            $ts = New-TimeSpan $itemLastUpdatedDate $Date
            
            # Compare number of days difference between updated and today, return if more than selected range, i.e. stale content
            if($ts.Days -ge $MaxDays) {
                $item
            }

        } else {
            $item
        }
    }
}

$items = @($root) + @(($root.Axes.GetDescendants())) | Where-LastUpdated -IsBefore:($selectedPeriod -eq 1) -MaxDays $selectedMaxDays | Initialize-Item

if($items.Count -eq 0) {
    Show-Alert "There are no inactive items within the specified time period"
} else {
    $props = @{
        Title = "Incative Items Report"
        InfoTitle = "Inactive items within $($selectedMaxDays) days"
        InfoDescription = "Lists all inactive items within $($selectedMaxDays) days."
        PageSize = 25
    }
    
    $items |
        Show-ListView @props -Property @{Label="Name"; Expression={$_.DisplayName} },
            @{Label="Updated"; Expression={$_.__Updated} },
            @{Label="Updated by"; Expression={$_."__Updated by"} },
            @{Label="Created"; Expression={$_.__Created} },
            @{Label="Created by"; Expression={$_."__Created by"} },
            @{Label="Path"; Expression={$_.ItemPath} }
}
Close-Window