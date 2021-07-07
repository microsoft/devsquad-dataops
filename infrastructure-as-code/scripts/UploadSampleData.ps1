param(
    [Parameter(Mandatory)] [string] $DeploymentOutputFile
)

Write-Host "Getting variables from $DeploymentOutputFile file..."
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable

Write-Host "Uploading files..."
$ResourceGroupName = $DeploymentOutput["resourceGroupData"]
$StorageAccountName = $DeploymentOutput["dataSourceStorageAccountName"]
$ContainerName = "flights-data"

$uploadStorage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

Set-AzStorageBlobContent -Container $ContainerName -File ../../sample-data/AirportCodeLocationLookupClean.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ../../sample-data/FlightDelaysWithAirportCodes.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ../../sample-data/FlightWeatherWithAirportCode.csv -Context $uploadStorage.Context -Force