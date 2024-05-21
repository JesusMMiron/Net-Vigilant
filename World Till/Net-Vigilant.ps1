####################################
##### Optima Net-Vigilant v1.0 #####
####################################
 
Write-Host ""
Write-Host "SportRadar Net-Vigilant 1.0"
Write-Host ""


#################################
#####  FUNCTIONS DEFINITION #####
#################################

###  Testing ENDPOINT status
function Test-ENDPOINT {
    param(
        [string]$ComputerName,
        [int]$Port
    )
 
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($ComputerName, $Port)
        if ($tcpClient.Connected) {
            return 1
        } else {
            return 0
        }
    } catch {
        return 0
    } finally {
        $tcpClient.Close()

    }
}


###  Checking if LOG name should be changed
function Set-LogPath {
    param(
        [string]$previousDate,
        [string]$logPath
    )
    try {
        $newdatetime = Get-Date
        $newformattedDate = $newdatetime.ToString("dd-MM-yyyy")
        
        if ($previousDate -ne $newformattedDate){
            # Ensure the directory exists, if not, create it.
            $directory = [System.IO.Path]::GetDirectoryName($logPath)
            if (-not (Test-Path -Path $directory)) {
                New-Item -Path $logPath -ItemType File
            }

            # Create the new log file
            $newLogPath = "$directory\$newformattedDate Net-Vigilant.log"
            New-Item -Path $newLogPath -ItemType File | Out-Null

            return $newLogPath
        } else {
            return $logPath
        }
    } catch {
        Write-Host "An error occurred: $_"
    }
}



###############################
##### VAR and Checkpoints #####
###############################

# 1 variable for date + hour // the other for only date
$datetime = Get-Date
$formattedDate = $datetime.ToString("dd-MM-yyyy")
$formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

# Setting log path
if (Test-Path "C:\ProgramData\Optima Information Services\World Till\Logs") {
    $logPath = "C:\ProgramData\Optima Information Services\World Till\Logs\$formattedDate Net-Vigilant.log"

    # Ensure the directory exists, if not, create it.
    $directory = [System.IO.Path]::GetDirectoryName($logPath)
    if (-not (Test-Path -Path $directory)) {
        New-Item -Path $logPath -ItemType File
    }
} 

# Set starting message on LOG
Add-Content -Path $logPath -Value "[$formattedDatetime] ### SportRadar Net-Vigilant started. ###"

# Status variable control. Starting value 1 = TRUE
$RTS_Last_Status = 1
$DELAWARE_Last_Status = 1
$UPDATER_Last_Status = 1




######################
##### WORLD TILL #####
###################### 


# Checking if World Till installation exists.
if (Test-Path ".\WorldTill.exe.settings.xml") {

    Write-Host -ForegroundColor Green "WorldTill.exe.settings.xml file found."
    Write-Host ""

    # Path definition
    $pathSettings = ".\WorldTill.exe.settings.xml"
    $configFilePath = "..\Update Service\OptimaUpdateService.exe.config"
    
    # Read the content of the files
    $xml = [xml](Get-Content $pathSettings)
    $configContent = Get-Content -Path $configFilePath -Raw
    
    # Gather endpoints from settings xml file
    $RTS_HOST = $xml.settings.property | Where-Object { $_.name -eq '$RTS_HOST' }
    $DELAWARE = $xml.settings.property | Where-Object { $_.name -eq '$DELAWARE' }

    # Gather FTP Optima Updater endpoint from config file
    $regex = [regex] 'ftp://([^"]+)"'
    $match = $regex.Match($configContent)
    if ($match.Success) {
        $UPDATER = $match.Groups[1].Value
        $ftpServer = $UPDATER -replace '^ftp://', ''
    }

    # Display the values from RTS_HOST and DELAWARE
    Write-Host -ForegroundColor Green "RTS endpoint is: $($RTS_HOST.'#text')"
    Write-Host -ForegroundColor Green "Delaware endpoint is: $($DELAWARE.'#text')"
    Write-Host -ForegroundColor Green "Optima Updater endpoint is: $ftpServer"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "Starting connectivity test now."
    Write-Host -ForegroundColor Yellow "Please close this window when you finish."
    Write-Host ""
    Write-Host -ForegroundColor Yellow "Logs can be found and reviewed here: $logPath"

    # Network check loop
    while ($true) {
        # Testing connectivity to endpoint through port 443. 
        # If ok it returns 1 if nok it returns 0.
        $RTS_Status = Test-ENDPOINT -ComputerName $($RTS_HOST.'#text') -Port 55555
        $DELAWARE_Status = Test-ENDPOINT -ComputerName $($DELAWARE.'#text') -Port 443
        $UPDATER_Status = Test-ENDPOINT -ComputerName $ftpServer -Port 21

        # Checking if new date for updating file log.
        $logPath = Set-LogPath -previousDate $formattedDate -logPath $logPath

        if ($RTS_Status -eq 0){
            # Gather the actual datetime and format to standard
            $datetime = Get-Date
            $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
     
            # Write in log the info
            Add-Content -Path $logPath -Value "[$formattedDatetime] RTS - DOWN"
            #### Write-Host -ForegroundColor Red "RTS Down"

            # Save last status in a loop external variable.
            $RTS_Last_Status = $RTS_Status
        }
     
        if ($DELAWARE_Status -eq 0){
            # Gather the actual datetime and format to standart
            $datetime = Get-Date
            $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
     
            # Write in log the info
            Add-Content -Path $logPath -Value "[$formattedDatetime] Delaware - DOWN"

            $DELAWARE_Last_Status = $DELAWARE_Status
        }

        if ($UPDATER_Status -eq 0){
            # Gather the actual datetime and format to standart
            $datetime = Get-Date
            $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
     
            # Write in log the info
            Add-Content -Path $logPath -Value "[$formattedDatetime] Optima Updater - DOWN"

            $UPDATER_Last_Status = $UPDATER_Status
        }


        # Reconnected service?
        if ($RTS_Last_Status -eq 0 -and $RTS_Status -eq 1){
            Add-Content -Path $logPath -Value "[$formattedDatetime] RTS - Reconnected"
            #### Write-Host -ForegroundColor Green "RTS Reconnected"
        }
        if ($DELAWARE_Last_Status -eq 0 -and $DELAWARE_Status -eq 1){
            Add-Content -Path $logPath -Value "[$formattedDatetime] DELAWARE - Reconnected"
        }
        if ($UPDATER_Last_Status -eq 0 -and $UPDATER_Status -eq 1){
            Add-Content -Path $logPath -Value "[$formattedDatetime] Optima Updater - Reconnected"
        }

        $RTS_Last_Status = $RTS_Status
        $DELAWARE_Last_Status = $DELAWARE_Status
        $UPDATER_Last_Status = $UPDATER_Status

        # Sleep for half second.
        Start-Sleep -Milliseconds 500
     
    }
}

