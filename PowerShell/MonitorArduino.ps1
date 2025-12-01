# Имя порта Ардуино (проверь в диспетчере устройств!)
$portName = "COM9"
$baudRate = 9600

# Путь к файлу для записи ключей
$outFile = "E:\GitHub\Student-Attendance-System-Arduino-RFID\Incoming_keys.txt"

# Время последней очистки
$lastFlush = Get-Date
$flushIntervalMinutes = 5

# Открыть COM-порт
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, 'None', 8, 'One'

try {
    $port.Open()
    Write-Output "Monitoring Arduino on $portName..."

    # Очистить файл перед началом
    Clear-Content $outFile -ErrorAction SilentlyContinue

    # Бесконечный цикл для чтения данных
    while ($true) {
        # Проверка, нужно ли очистить файл по времени
        $now = Get-Date
        if (($now - $lastFlush).TotalMinutes -ge $flushIntervalMinutes) {
            Clear-Content $outFile -ErrorAction SilentlyContinue
            $lastFlush = $now
            Write-Output "🧹 File cleared at $now"
        }

        # Чтение данных из порта
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
    # Очистка и закрытие при завершении скрипта
    if ($port.IsOpen) { $port.Close() }
    Clear-Content $outFile -ErrorAction SilentlyContinue
    Write-Output "🚪 Port closed and file cleared on exit."
}
