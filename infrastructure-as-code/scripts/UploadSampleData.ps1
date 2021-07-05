param(
    [Parameter(Mandatory)] [string] $DeploymentOutputFile
)

Write-Host "Getting variables from $DeploymentOutputFile file..."
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable

Write-Host "Uploading files..."
$StorageAccountName = $DeploymentOutput["dataSourceStorageAccountName"]
$ContainerName = "flights-data"
az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name AirportCodeLocationLookupClean.csv --file sample-data/AirportCodeLocationLookupClean.csv
az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name FlightDelaysWithAirportCodes.csv --file sample-data/FlightDelaysWithAirportCodes.csv
az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name FlightWeatherWithAirportCode.csv --file sample-data/FlightWeatherWithAirportCode.csv