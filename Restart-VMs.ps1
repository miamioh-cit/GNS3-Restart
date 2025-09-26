param(
    [string]$vCenterServer,
    [string]$vCenterUser,
    [string]$vCenterPass,

    # Change these if your structure differs
    [string]$ParentFolderName = "CIT",
    [string[]]$TargetFolderNames = @("281","284","358"),

    # CSV export path for discovery results
    [string]$ExportCsvPath = ".\vm-folder-inventory.csv"
)

# Ignore invalid or self-signed SSL certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User | Out-Null

# Connect to the vCenter Server using the provided credentials
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPass | Out-Null

try {
    # --- FIXED: path builder without Select-Object -Reverse ---
    function Get-FullPath {
        param([Parameter(Mandatory)]$Object)
        $names = @()
        $cur = $Object
        while ($null -ne $cur) {
            if ($cur.PSObject.Properties.Match('Name').Count -gt 0) { $names += $cur.Name }
            if ($cur.PSObject.Properties.Match('Parent').Count -gt 0) { $cur = $cur.Parent } else { break }
        }
        [array]::Reverse($names)
        return ($names -join '/')
    }

    Write-Host "`n=== DISCOVERY MODE ===" -ForegroundColor Cyan
    Write-Host "Parent Folder: $ParentFolderName; Target Sub-Folders: $($TargetFolderNames -join ', ')" -ForegroundColor Cyan

    # Try to grab the parent folder if it exists
    $parentFolder = Get-Folder -Name $ParentFolderName -ErrorAction SilentlyContinue

    # Locate each target (Folder/ResourcePool/vApp)
    $targetContainers = @()
    foreach ($name in $TargetFolderNames) {
        # Folder under parent
        if ($parentFolder) {
            $f = Get-Folder -Name $name -Location $parentFolder -ErrorAction SilentlyContinue
            if ($f) { $targetContainers += $f; continue }
        }
        # Folder anywhere
        $f2 = Get-Folder -Type VM -Name $name -ErrorAction SilentlyContinue
        if ($f2) { $targetContainers += $f2; continue }

        # Resource pool
        $rp = Get-ResourcePool -Name $name -ErrorAction SilentlyContinue
        if ($rp) { $targetContainers += $rp; continue }

        # vApp
        $va = Get-VApp -Name $name -ErrorAction SilentlyContinue
        if ($va) { $targetContainers += $va; continue }

        Write-Warning "Nothing found for '$name' under CIT or globally — skipping."
    }

    if ($targetContainers) {
        $summaryRows = foreach ($c in $targetContainers) {
            $vms = Get-VM -Location $c -ErrorAction SilentlyContinue
            [PSCustomObject]@{
                Type            = $c.GetType().Name
                Name            = $c.Name
                FullPath        = Get-FullPath $c
                VM_Count        = ($vms | Measure-Object).Count
                PoweredOn_Count = ($vms | Where-Object {$_.PowerState -eq 'PoweredOn'} | Measure-Object).Count
                SampleVMs       = ($vms | Select-Object -First 3 -ExpandProperty Name) -join ', '
            }
        }
        $summaryRows | Format-Table -AutoSize
        $summaryRows | Export-Csv -Path $ExportCsvPath -NoTypeInformation -Encoding UTF8
        Write-Host "`nInventory exported to: $ExportCsvPath`n" -ForegroundColor DarkGreen
    } else {
        Write-Warning "No target folders/resource pools/vApps found. Nothing to do."
        return
    }
}
finally {
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false | Out-Null
}
