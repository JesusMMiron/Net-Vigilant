####################################
##### Optima Net-Vigilant v1.0 #####
####################################
 
Write-Host ""
Write-Host "Net-Vigilant 1.0"
Write-Host ""

# Setting log path
if (Test-Path "C:\ProgramData\Optima Information Services\World Till\Logs") {
    $logPath = "C:\ProgramData\Optima Information Services\World Till\Logs\Net-Vigilant.log"
} else {
    if (Test-Path "C:\Program Files (x86)\Serverless\Logs") {
        $logPath = "C:\Program Files (x86)\Serverless\Logs\Net-Vigilant.log"
    } 
}

# Set starting time and message on LOG
$datetime = Get-Date
$formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
Add-Content -Path $logPath -Value "[$formattedDatetime] ### SportRadar Net-Vigilant started. ###"

# Status variable TODO
$RTS_Last_Status = 1
$DELAWARE_Last_Status = 1
$UPDATER_Last_Status = 1
$RDP_Last_Status = 1




######################
##### WORLD TILL #####
######################


# Checking if World Till installation exists.

    if (Test-Path "C:\Program Files (x86)\Optima Information Services\World Till") {
        
        Write-Host -ForegroundColor Green "WorldTill found."
 
        if (Test-Path "C:\Program Files (x86)\Optima Information Services\World Till\WorldTill.exe.settings.xml") {
            
            Write-Host -ForegroundColor Green "WorldTill settings file found."
 
            # Path definition
            $pathSettings = "C:\Program Files (x86)\Optima Information Services\World Till\WorldTill.exe.settings.xml"
            $configFilePath = "C:\Program Files (x86)\Optima Information Services\Update Service\OptimaUpdateService.exe.config"
            
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
                $ftpServer = $uriValue -replace '^ftp://', ''
            }

            # Display the values from RTS_HOST and DELAWARE
            Write-Host -ForegroundColor Green "RTS endpoint is: $($RTS_HOST.'#text')"
            Write-Host -ForegroundColor Green "Delaware endpoint is: $($DELAWARE.'#text')"
            Write-Host -ForegroundColor Green "Optima Updater endpoint is: $ftpServer"
             
            # Network check loop
            while ($true) {
                # Testing connectivity to endpoint through port 443. 
                # If ok it returns 1 if nok it returns 0.
                $RTS_Status = Test-ENDPOINT -ComputerName $($RTS_HOST.'#text') -Port 55555
                $DELAWARE_Status = Test-ENDPOINT -ComputerName $($DELAWARE.'#text') -Port 443
                $UPDATER_Status = Test-ENDPOINT -ComputerName $ftpServer -Port 21

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
                    Add-Content -Path $logPath -Value "[$formattedDatetime] FTP - Reconnected"
                }

                $RTS_Last_Status = $RTS_Status
                $DELAWARE_Last_Status = $DELAWARE_Status
                $UPDATER_Last_Status = $UPDATER_Status

                # Sleep for half second.
                Start-Sleep -Milliseconds 500
             
            }
        }
    } else {
        Write-Host -ForegroundColor Red "WorldTill not found."
    }




########################
##### Betting Till #####
########################

# Endpoints definitions:
$BO = "botilltsg.optimahq.com"
$DP = "dptilltsg2.optimahq.com"
$SG = "sgtilltsg.optimahq.com"


# Checking if Betting Till installation exists.
    if (Test-Path "C:\Program Files (x86)\Serverless") {
                
        Write-Host -ForegroundColor Green "Serverless found."
        # REGEDIT path to investigate
        $regeditPath = "HKCU:\Software\Microsoft\Terminal Server Client\Servers"
        
        # Obtain the KEYS from the path
        $subKey = Get-ChildItem -Path $regeditPath
        
        # Var creation
        $regeditPathChars = $null
        
        # Working on each key listed
        foreach ($subKey in $subKey) {
            # Checking if the key contains "UK-"
            if ($subKey.Name -like "*UK-*") {
                Write-Host -ForegroundColor Green "Key found: $subKey"
                # Extract chars position to know the customer.
                $regeditPathChars = $subKey.Name.Substring(71, 2)
                break  # End loop if key with 'UK-' found.
            }
        }
        
        # Display the chars found
        if ($regeditPathChars -ne $null) {
            Write-Host -ForegroundColor Green "The customer name is: $regeditPathChars"
            
            # Network check loop
            while ($true) {

                # Checking if BAR ONE RACING
                if ($regeditPathChars -eq "BO") {

                    $RDP_Status = Test-ENDPOINT -ComputerName $BO -Port 443
                    
                    if ($RDP_Status -eq 0){
                        # Gather the actual datetime and format to standart
                        $datetime = Get-Date
                        $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
                        
                        # Write in log the info
                        Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $BO - DOWN"
                    }
                }

                # Checking if DAVID PLUCK
                if ($regeditPathChars -eq "DP") {

                    $RDP_Status = Test-ENDPOINT -ComputerName $DP -Port 443

                    if ($RDP_Status -eq 0){
                        # Gather the actual datetime and format to standart
                        $datetime = Get-Date
                        $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
                        
                        # Write in log the info
                        Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $DP - DOWN"
                    }
                }

                # Checking if SEANGRAHAM
                if ($regeditPathChars -eq "SG") {

                    $RDP_Status = Test-ENDPOINT -ComputerName $SG -Port 443
                
                    if ($RDP_Status -eq 0){
                        # Gather the actual datetime and format to standart
                        $datetime = Get-Date
                        $formattedDatetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")
                        
                        # Write in log the info
                        Add-Content -Path $logPath -Value "[$formattedDatetime] Endpoint $SG - DOWN"
                    }
                }

                # Sleep for half second.
                Start-Sleep -Milliseconds 500
            }
        }

        else {
            Write-Host -ForegroundColor Red "No customer found on REGEDIT path with 'UK-'"
        }
    }
        else {
        Write-Host -ForegroundColor Red "Serverless not found on path 'C:\Program Files (x86)\Serverless'"
    }



 
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
        if ($tcpClient) {
            $tcpClient.Close()
        }
    }
}
 
 
