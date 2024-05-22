####################################
##### Optima Net-Vigilant v1.0 #####
####################################
 
Write-Host ""
Write-Host -ForegroundColor Green "Net-Vigilant 1.0"
Write-Host ""


######################
#####  FUNCTIONS #####
######################

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
        Write-Host "Could not set log path."
    }
}






###############################
##### VAR and Checkpoints #####
###############################

# Endpoint definition:
$DP = "dptilltsg2.optimahq.com"

# 1 variable for date + hour // the other for only date
$datetime = Get-Date
$formattedDate = $datetime.ToString("dd-MM-yyyy")
$formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

# Setting log path
if (Test-Path "C:\Program Files (x86)\Serverless\Logs") {
    $logPath = "C:\Program Files (x86)\Serverless\Logs\$formattedDate Net-Vigilant.log"

    # Ensure the directory exists, if not, create it.
    $directory = [System.IO.Path]::GetDirectoryName($logPath)
    if (-not (Test-Path -Path $directory)) {
        New-Item -Path $logPath -ItemType File
    }
} 



# Status variable for recoonections. Start value 1 = true
$RDP_Last_Status = 1
$RDP_Last_Status_online = 1




########################
##### Betting Till #####
########################

Write-Log -logPath $logPath -formattedDatetime $formattedDatetime -prevStatus $prevStatus -actualStatus $actualStatus

function Write-Log {
    param(
        [string]$logPath,
        [string]$formattedDatetime,
        [int]$prevStatus,
        [int]$actualStatus
    )
    try {
            if ($null){
            # Chek of log exist
            # if not, create log and write message (check if reconnected)
            # if exist, write message (check if reconnected)
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint GOOGLE - DOWN"
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - Reconnected"
        } 
    } catch {
        Write-Host "Could not create log."
    }
}
##########################

# Checking if Betting Till installation exists.
    if (Test-Path "C:\Program Files (x86)\Serverless") {

        Write-Host -ForegroundColor Green "Checking endpoint to $DP"

        # Set starting time and message on LOG
        Add-Content -Path $logPath -Value "[$formattedDatetime] ### SportRadar Net-Vigilant started. ###"

        # Network check loop
        while ($true) {

            # Checking if new date for updating file log.
            $logPath = Set-LogPath -previousDate $formattedDate -logPath $logPath 


            $RDP_Status = Test-ENDPOINT -ComputerName $DP -Port 443
            $RDP_Status_online = Test-ENDPOINT -ComputerName "google.com" -Port 443

            # Gather the actual datetime and format to standart
            $datetime = Get-Date
            $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")


            if ($RDP_Status -eq 0){
                # Write in log the info
                Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - DOWN"
            }

            if ($RDP_Status_online -eq 0){
                # Write in log the info
                Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint GOOGLE - DOWN"
            }


            # Reconnected service?
            if ($RDP_Last_Status -eq 0 -and $RDP_Status -eq 1){
                Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - Reconnected"
            }
            if ($RDP_Last_Status_online -eq 0 -and $RDP_Status_online -eq 1){
                Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint GOOGLE - Reconnected"
            }

            $RDP_Last_Status = $RDP_Status
            $RDP_Last_Status_online = $RDP_Status_online

            # Sleep for half second.
            Start-Sleep -Milliseconds 500
        }
    }
        else {
        Write-Host -ForegroundColor Red "Serverless not found on path 'C:\Program Files (x86)\Serverless'"
    }
