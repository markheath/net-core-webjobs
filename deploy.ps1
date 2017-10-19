# variables
$resourceGroup = "WebJobsCoreTest"
$location = "westeurope"
$appName = "webjobscoretest1"
$planName = "webjobscoreplan"

# create resource group
az group create -n $resourceGroup -l $location

# create the app service plan
az appservice plan create -n $planName -g $resourceGroup -l $location --sku B1

# create the webapp
az webapp create -n $appName -g $resourceGroup --plan $planName

# get the deployment credentials
$user = az webapp deployment list-publishing-profiles -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userName" -o tsv

$pass = az webapp deployment list-publishing-profiles -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userPWD" -o tsv

# basic auth with Invoke-WebRequest: https://stackoverflow.com/a/27951845/7532
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

$sourceFilePath = "publish.zip" # this is what you want to go into wwwroot

# use kudu deploy from zip file
Invoke-WebRequest -Uri https://$appName.scm.azurewebsites.net/api/zipdeploy -Headers $Headers `
    -InFile $sourceFilePath -ContentType "multipart/form-data" -Method Post

# launch kudu
Start-Process https://$appName.scm.azurewebsites.net

# tear-down
#az group delete -n $resourceGroup --yes