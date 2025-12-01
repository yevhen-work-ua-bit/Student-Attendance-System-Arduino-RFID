param (
    [string]$Key
)

$logFile = "E:\GitHub\Student-Attendance-System-Arduino-RFID\log_arduino.txt"
$logStamp = "==== $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss') ===="

Add-Content $logFile "`r`n$logStamp"
Add-Content $logFile "Key entered: $Key"

if (-not $Key -or $Key.Length -ne 16) {
    Add-Content $logFile "❌ Invalid key length!"
    Write-Host "The key must contain exactly 16 characters!"
    pause
    exit
}

try {
    # Opening COM port
    $port = New-Object System.IO.Ports.SerialPort "COM9", 9600, 'None', 8, 'One'
    $port.ReadTimeout = 500  # 0.5 second timeout for faster reaction
    $port.Open()

    Start-Sleep -Milliseconds 10000

    # Sending command on Arduino 
    $port.WriteLine("1")
    Add-Content $logFile "✅ Sent WRITE command (1)."
    Start-Sleep -Milliseconds 1000

    # Sending identification code on Arduino to writing on students card
    $port.WriteLine($Key)
    Add-Content $logFile "✅ Key sent: $Key"
    Write-Host "✅ Key sent to Arduino. Listening for responses..."

    $timeoutSeconds = 10
    $startTime = Get-Date

    while ((Get-Date) -lt $startTime.AddSeconds($timeoutSeconds)) {
        try {
            $line = $port.ReadLine()
            if ($line) {
                $line = $line.Trim()
                Write-Host "Arduino: $line"
                Add-Content $logFile "Arduino: $line"

                # If Arduino says "Ready" or similar — can break early
                if ($line -match "Key successfully written|Error writing key|Invalid key length") {
                    break
                }
            }
        } catch {
            # Ignore timeout errors
        }
    }

    $port.Close()
}
catch {
    Write-Host "❌ Error: $_"
    Add-Content $logFile "❌ Error: $_"
}

pause
