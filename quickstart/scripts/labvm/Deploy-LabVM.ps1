param (
    [string]$sourceVhd = 'https://stlabvm.blob.core.windows.net/vhd/labvm-001.vhd',

    # Size of the VHD snapshot in bytes
    [long]$vhdSizeBytes = 136367309312,

    # Region to deploy the VM
    [string]$location = 'eastus',

    # VM resource group
    [string]$resourceGroupName = 'rg-labvm',

    # disk VM name
    [string]$diskName = 'disklabvmeastus'
)

Write-Host "[DevSquad In a Day] Initializing the lab VM disk"

$diskconfig = New-AzDiskConfig -SkuName 'Premium_LRS' -OsType 'Windows' -UploadSizeInBytes $vhdSizeBytes -Location $location -CreateOption 'Upload'

New-AzResourceGroup $resourceGroupName -Location $location

New-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -Disk $diskconfig

$diskSas = Grant-AzDiskAccess -ResourceGroupName $resourceGroupName -DiskName $diskName -DurationInSecond 86400 -Access 'Write'

$disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName

Write-Host "[DevSquad In a Day] Copying the lab VM snapshot to your subscription"

azcopy copy $sourceVhd $diskSas.AccessSAS --blob-type PageBlob

Revoke-AzDiskAccess -ResourceGroupName $resourceGroupName -DiskName $diskName

Write-Host "[DevSquad In a Day] Creating the lab VM associated resources"

$subnetName = 'labDsiadSubNet'
$singleSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix 10.0.0.0/24

$vnetName = "labDsiadVnet"
$vnet = New-AzVirtualNetwork `
    -Name $vnetName -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix 10.0.0.0/16 `
    -Subnet $singleSubnet


$nsgName = "labDsiadNsg"
$rdpRule = New-AzNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $nsgName -SecurityRules $rdpRule

$ipName = "labDsiadIP"
$pip = New-AzPublicIpAddress `
    -Name $ipName -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AllocationMethod Dynamic

$nicName = "labDsiadNicName"
$nic = New-AzNetworkInterface -Name $nicName `
    -ResourceGroupName $resourceGroupName `
    -Location $location -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $pip.Id `
    -NetworkSecurityGroupId $nsg.Id

$vmName = "vm-lab"
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_E2s_v3"

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id `
    -CreateOption Attach -Windows

$vm = Set-AzVMBootDiagnostic -VM $vm -Disable

Write-Host "[DevSquad In a Day] Creating the lab VM"

New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm

Write-Host "[DevSquad In a Day] Done!"
