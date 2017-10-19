$publishFolder = "publish"

# delete any previous publish
if(Test-path $publishFolder) {Remove-Item -Recurse -Force $publishFolder}

# publish the webjobs
dotnet publish triggered1 -c Release -o ..\$publishFolder\app_data\jobs\triggered\triggered1
Copy-Item triggered1\run.cmd publish\app_data\jobs\triggered\triggered1

dotnet publish scheduled1 -c Release -o ..\$publishFolder\app_data\jobs\triggered\scheduled1
Copy-Item scheduled1\run.cmd publish\app_data\jobs\triggered\scheduled1
Copy-Item scheduled1\settings.job publish\app_data\jobs\triggered\scheduled1

dotnet publish continuous1 -c Release -o ..\$publishFolder\app_data\jobs\continuous\continuous1
Copy-Item continuous1\run.cmd publish\app_data\jobs\continuous\continuous1
Copy-Item continuous1\settings.job publish\app_data\jobs\continuous\continuous1

# zip the publish folder
$destination = "publish.zip"
if(Test-path $destination) {Remove-item $destination}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($publishFolder, $destination)
