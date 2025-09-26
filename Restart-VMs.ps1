param(
  [Parameter(Mandatory=$true)][string]$vCenterServer,
  [Parameter(Mandatory=$true)][string]$vCenterUser,
  [Parameter(Mandatory=$true)][string]$vCenterPass,

  # EXACT targets
  [string]$ParentRootPath = "CIT/vm",                 # full path prefix
  [string[]]$TargetFolderNames = @("281","284","358") # only these folders
)

# --- Setup -----------------------------------------------------------------
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User | Out-Null
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPass | Out-Null

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

try {
  # --- Find ONLY the allowed folders by (name + exact path prefix) ----------
  $allCandidateFolders = Get-Folder -Type VM | Where-Object {
    $_.Name -in $TargetFolderNames -and (Get-FullPath $_) -like "$ParentRootPath/*"
  }

  # Keep only folders whose full path exactly matches CIT/vm/<name>
  $allowedFolders = foreach ($f in $allCandidateFolders) {
    $fp = Get-FullPath $f
    $name = $f.Name
    if ($fp -eq "$ParentRootPath/$name") { $f }
  }

  if (-not $allowedFolders) {
    Write-Error "No matching folders found under '$ParentRootPath' for: $($TargetFolderNames -join ', ')"
    return
  }

  Write-Host "Approved folders:" -ForegroundColor Cyan
  $allowedFolders | ForEach-Object { Write-Host ("  - " + (Get-FullPath $_)) }

  # --- Collect VMs ONLY from those folders ---------------------------------
  $targetVMs = $allowedFolders | ForEach-Object { Get-VM -Location $_ } | Sort-Object Name -Unique

  if (-not $targetVMs) {
    Write-Host "No VMs found in the approved folders. Exiting."
    return
  }

  # Restrict again per-VM by folder path (belt & suspenders safety)
  $approvedPaths = $allowedFolders | ForEach-Object { Get-FullPath $_ }
  $safeVMs = foreach ($vm in $targetVMs) {
    try {
      $vmFolder = $vm.Folder
      $vmFolderPath = if ($vmFolder) { Get-FullPath $vmFolder } else { "" }
      if ($approvedPaths -contains $vmFolderPath) { $vm }
    } catch { }
  }

  if (-not $safeVMs) {
    Write-Host "No VMs passed path verification. Exiting."
    return
  }

  $poweredOn = $safeVMs | Where-Object { $_.PowerState -eq 'PoweredOn' }
  if (-not $poweredOn) {
    Write-Host "No powered-on VMs in approved folders. Nothing to restart."
    return
  }

  Write-Host "Hard-rebooting $($poweredOn.Count) VM(s) from approved folders..." -ForegroundColor Green
  foreach ($vm in $poweredOn) {
    try {
      Write-Host "Hard reboot (Restart-VM) for: $($vm.Name)"
      Restart-VM -VM $vm -Confirm:$false -ErrorAction Stop
    } catch {
      Write-Error "Failed to hard reboot '$($vm.Name)'. Error: $_"
    }
  }

  Write-Host "Done." -ForegroundColor Green
}
finally {
  Disconnect-VIServer -Server $vCenterServer -Confirm:$false | Out-Null
}

