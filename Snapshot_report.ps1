Write-Host "
***********************************
**   VMware Snapshot Report   **
***********************************
"

if (Get-PSSnapin vmware* -ErrorAction SilentlyContinue) {
Write-Host "vSphere snapin already loaded, proceeding."
} else {
Write-Host "Loading vSphere snapin."
Add-pssnapin VMWare.VimAutomation.Core -ErrorAction SilentlyContinue
    if (Get-PSSnapin vmware* -ErrorAction SilentlyContinue) {
    Write-Host "vSphere snapin loaded"
    } else {
    Write-Host -ForegroundColor Red "Error loading vSphere snapin. Halting."
    Write-Host -ForegroundColor Red "VMware PowerCLI is required to run this script."
    break
    }
 }

$date = Get-Date -uformat "%Y-%m-%d"
$vcenter = Read-Host "Please enter the name of your vCenter"

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

Write-host "
****************************
Starting Snapshot Collection 
****************************
"

$results =@()
$vms = (Get-VM | Get-Snapshot) 

foreach ($vm in $vms) 
{
	$row = "" | Select VMName, CreationDate, SizeGB, PrimaryAdmin, vCenterName, FQDN, SnapshotName, Description
    Write-Host $vm.VM "Started"
	$row.VMName = $vm.VM
	$row.CreationDate = $vm.Created
	$row.SizeGB = $vm.SizeGB	
    $row.PrimaryAdmin = (Get-TagAssignment -Entity $vm.VM -Category "PrimaryAdmin" | foreach {$_.Tag} | foreach {$_.Name})
	$row.vCenterName = $vCenter
	$row.FQDN = $vm.VM.Guest.HostName
	$row.SnapshotName = $vm.Name
	$row.Description = $vm.Description
	$results += $row
	Write-Host $vm.VM "Finished"
}

$results | Export-Csv "$env:userprofile\Desktop\Snapshots.$vcenter.$date.csv" -UseCulture -NoTypeInformation

Write-host "
****************************
Snapshot Collection Complete
****************************
"

Disconnect-VIServer * -Confirm:$False
Write-Host "Disconnected from $vCenter"
Write-Host "Script complete"