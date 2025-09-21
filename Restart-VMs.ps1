param(
    [string]$vCenterServer,
    [string]$vCenterUser,
    [string]$vCenterPass,

    # Change these if your structure differs
    [string]$ParentFolderName = "CIT",
    [string[]]$TargetFolderNames = @("281","284","358")
)

# Ignore invalid or self-signed SSL certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User | Out-Null

# Connect to the vCenter Server using the provided credentials
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPass | Out-Null

try {
    # Locate the parent folder (e.g., "CIT")
    $parentFolder = Get-Folder -Name $ParentFolderName -ErrorAction Stop

    # Locate each target sub-folder (e.g., 281, 284, 358) under the parent
    $targetFolders = foreach ($name in $TargetFolderNames) {
        try {
            Get-Folder -Name $name -Location $parentFolder -ErrorAction Stop
        } catch {
            Write-Warning "Folder '$name' not found under '$ParentFolderName' — skipping."
        }
    }

    if (-not $targetFolders) {
        Write-Warning "No target folders found. Nothing to do."
        return
    }

    # Collect VMs from those folders
    $vms = $targetFolders | ForEach-Object { Get-VM -Location $_ } | Sort-Object Name -Unique
    if (-not $vms) {
        Write-Warning "No VMs found in $($TargetFolderNames -join ', ')."
        return
    }

    # Only restart powered-on VMs (skip powered-off)
    $poweredOnVMs = $vms | Where-Object { $_.PowerState -eq 'PoweredOn' }
    if (-not $poweredOnVMs) {
        Write-Host "All VMs are powered off. Nothing to restart."
        return
    }

    foreach ($vm in $poweredOnVMs) {
        try {
            Write-Host "Attempting guest restart for VM: $($vm.Name)"
            Restart-VMGuest -VM $vm -Confirm:$false -ErrorAction Stop
        } catch {
            Write-Warning "Guest restart failed (Tools not running?) on '$($vm.Name)'. Power-cycling..."
            try {
                Restart-VM -VM $vm -Confirm:$false -ErrorAction Stop
            } catch {
                Write-Error "Failed to restart VM '$($vm.Name)'. Error: $_"
            }
        }
    }
}
finally {
    # Disconnect from the vCenter Server after operations
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false | Out-Null
}
