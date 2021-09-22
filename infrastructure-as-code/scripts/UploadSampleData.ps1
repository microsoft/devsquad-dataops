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

mkdir ./sample-data
$samplesStorage = 'https://stlabvm.blob.core.windows.net/sample-data/'
$sampleFiles = ('FlightWeatherWithAirportCode.csv','FlightDelaysWithAirportCodes.csv','AirportCodeLocationLookupClean.csv')

foreach ($sample in $sampleFiles){
    Invoke-WebRequest -Uri $samplesStorage$sample -OutFile "./sample-data/$sample"
}

Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/AirportCodeLocationLookupClean.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/FlightDelaysWithAirportCodes.csv -Context $uploadStorage.Context -Force
Set-AzStorageBlobContent -Container $ContainerName -File ./sample-data/FlightWeatherWithAirportCode.csv -Context $uploadStorage.Context -Force