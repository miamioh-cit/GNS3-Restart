param(
    [string]$vCenterServer
)

# List of VMs to restart
$vmList = @(
    "284-01", "284-02", "284-03", "284-04", "284-05", "284-06", "284-07", "284-08", "284-09", "284-10",
    "284-11", "284-12", "284-13", "284-14", "284-15", "284-16", "284-17", "386-00", "386-01", "358-01"
)

# Retrieve vSphere credentials from Jenkins
$credential = Get-Credential -UserName '$env:VCENTER_USER' -Message "roseaw-vsphere-creds"
$vCenterUser = $credential.UserName
$vCenterPass = $credential.GetNetworkCredential().Password

# Connect to the vCenter Server
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPass

# Loop through each VM name and restart the VM
foreach ($vmName in $vmList) {
    $vm = Get-VM -Name $vmName
    if ($vm -ne $null) {
        Write-Host "Restarting VM: $vmName"
        Restart-VMGuest -VM $vm -Confirm:$false
    } else {
        Write-Host "VM not found: $vmName"
    }
}

# Disconnect from the vCenter Server
Disconnect-VIServer -Server $vCenterServer -Confirm:$false