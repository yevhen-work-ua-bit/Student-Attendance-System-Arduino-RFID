# COM port Arduino
$portName = "COM9"
$baudRate = 9600

# Path to the file for writing keys
$outFile = "E:\GitHub\Student-Attendance-System-Arduino-RFID\Incoming_keys.txt"

# Last cleaning time
$lastFlush = Get-Date
$flushIntervalMinutes = 5

# Opening COM port
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, 'None', 8, 'One'

try {
    $port.Open()
    Write-Output "Monitoring Arduino on $portName..."

    Clear-Content $outFile -ErrorAction SilentlyContinue

    # Reading data from a file
    while ($true) {
        $now = Get-Date
        if (($now - $lastFlush).TotalMinutes -ge $flushIntervalMinutes) {
            Clear-Content $outFile -ErrorAction SilentlyContinue
            $lastFlush = $now
            Write-Output "🧹 File cleared at $now"
        }

        # Reading data from a COM port
        if ($port.BytesToRead -gt 0) {
            $line = $port.ReadLine().Trim()
            if ($line -like "Encrypted Key (ASCII)*") {
                $key = $line.Replace("Encrypted Key (ASCII):", "").Trim()
                Add-Content -Path $outFile -Value $key
                Write-Output "✅ Received key: $key"
            }
        }

        Start-Sleep -Milliseconds 200
    }
}
finally {
    
    if ($port.IsOpen) { $port.Close() }
    Clear-Content $outFile -ErrorAction SilentlyContinue
    Write-Output "🚪 Port closed and file cleared on exit."
}
