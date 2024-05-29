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


function Writelog {
    param(
        [string]$logPath,               # Windows Path
        [string]$formattedDatetime,     # dd-MM-yyyy 
        [int]$StatusRDP,                # 1 up // 0 down
        [int]$StatusONLINE,             # 1 up // 0 down
        [int]$prevStatusRDP,            # 1 up // 0 down
        [int]$prevStatusONLINE          # 1 up // 0 down
    )
    try {
        
        # Chek of log exist
        if (-not (Test-Path -Path $logPath)){
            New-Item -Path $logPath -ItemType File
            Add-Content -Path $logPath -Value "[$formattedDatetime] WARN!! Log was created back due deletion."
        }

        # Write in log the info
        if ($StatusRDP -eq 0){
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - DOWN"
        }
        
        # Write in log the info
        if ($StatusONLINE -eq 0){
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint GOOGLE - DOWN"
        }

        #  write message (check if reconnected)
        if ($prevStatusRDP -eq 0 -and $StatusRDP -eq 1){
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - Reconnected"
        }

        #  write message (check if reconnected)
        if ($prevStatusONLINE -eq 0 -and $StatusONLINE -eq 1){
            Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint GOOGLE - Reconnected"
        }
    } catch {
        Write-Host "Could not create or writing the log."
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
$ONLINE_Last_Status = 1




########################
##### Betting Till #####
########################


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
		$ONLINE_Status = Test-ENDPOINT -ComputerName "google.com" -Port 443

		# Gather the actual datetime and format to standart
		$datetime = Get-Date
		$formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

		Writelog -logPath $logPath -formattedDatetime $formattedDatetime -StatusRDP $RDP_Status -StatusONLINE $ONLINE_Status -prevStatusRDP $RDP_Last_Status -prevStatusONLINE $ONLINE_Last_Status

		$RDP_Last_Status = $RDP_Status
		$ONLINE_Last_Status = $ONLINE_Status

		# Sleep for half second.
		Start-Sleep -Milliseconds 500
	}
}	else {
	Write-Host -ForegroundColor Red "Serverless not found on path 'C:\Program Files (x86)\Serverless'"
}
