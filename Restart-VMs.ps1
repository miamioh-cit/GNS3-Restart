param(
    [string]$vCenterServer,
    [string]$vCenterUser,
    [string]$vCenterPass
)

# Ignore invalid or self-signed SSL certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User

# Connect to the vCenter Server using the provided credentials
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPass

# List of VMs to restart
$vmList = @(
    "284-01", "284-02", "284-03", "284-04", "284-05", "284-06", "284-07", "284-08", "284-09", "284-10",
    "284-11", "284-12", "284-13", "284-14", "284-15", "284-16", "284-17", "386-00", "386-01",
    "358-01", "358-02", "358-03", "358-04", "358-05", "358-06", "358-07", "358-08", "358-09", "358-10",
    "358-11", "358-12", "358-13", "358-14",
    "281K-01", "281K-02", "281K-03", "281K-04", "281K-05",
    "281-01", "281-02", "281-03", "281-04", "281-05", "281-06", "281-07", "281-08", "281-09", "281-10", 
    "281-11", "281-12", "281-13", "281-14"


)

# Loop through each VM name and restart the VM if found
foreach ($vmName in $vmList) {
    try {
        $vm = Get-VM -Name $vmName
        if ($vm -ne $null) {
            Write-Host "Restarting VM: $vmName"
            Restart-VMGuest -VM $vm -Confirm:$false
        } else {
            Write-Host "VM not found: $vmName"
        }
    } catch {
        Write-Host "Error processing VM: $vmName. Error: $_"
    }
}

# Disconnect from the vCenter Server after operations
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
