param(
    [Parameter(Mandatory)] [string] $DeploymentOutputFile
)

Write-Host "Unzip sample-data..."
mkdir ./sample-data

$zipFiles = ('FlightWeatherWithAirportCode.zip', 'FlightDelaysWithAirportCodes.zip', 'AirportCodeLocationLookupClean.zip')
$zipPath = '../infrastructure/sample-data/'

foreach ($zipFile in $zipFiles){
    $file = ($zipPath + $zipFile)
    Write-Host "File " $file
    Expand-Archive -path $file -destinationpath './sample-data/'
}

Write-Host "Getting variables from $DeploymentOutputFile file..."
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable

Write-Host "Uploading files..."
$ResourceGroupName = $DeploymentOutput["resourceGroupData"]
$StorageAccountName = $DeploymentOutput["dataSourceStorageAccountName"]


$uploadStorage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$ContainerName = "flights-data"

Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/AirportCodeLocationLookupClean.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/FlightDelaysWithAirportCodes.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/FlightWeatherWithAirportCode.csv -Context $uploadStorage.Context -Force

Write-Host "Files uploaded!"