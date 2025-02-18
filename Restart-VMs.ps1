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
    "25-alexanmf", "25-alir2", "25-almafrtk", "25-barillnt", "25-beimesca", "25-benzink", "25-blairc", "25-bosticdj", "25-bowman37", "25-brownc61",
    "25-burkhejl", "25-careyjr", "25-clarkap2", "25-cryselka", "25-davenpr2", "25-diallof2", "25-ehlerjl", "25-eschenea", "25-fangmaj2", "25-ferrana", 
    "25-fishe192", "25-gartnea", "25-guzmanma", "25-hertleac", "25-hibbarkm", "25-hoganec", "25-jonesm64", "25-khanalb", "25-leachh", "25-lieuhk", 
    "25-mcclela", "25-mooreac5", "murrayt6", "25-nguyenjm", "25-nolen", "25-parsonjt", "25-perezi3", "25-rimalgp", "25-rodrig99", "25-roger142",
    "25-samals", "25-sanwuya", "25-sapkotp", "25-smith624", "25-stidhalt", "25-thiekend", "25-vontrodl", "25-wattsts", "25-widenemg", "25-wilso682", 
    "25-yharbrm", "25-hibbardkm"

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
