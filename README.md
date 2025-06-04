# Monitor for 60 seconds
$duration = 60
$interval = 5
$endTime = (Get-Date).AddSeconds($duration)
$results = @()

while ((Get-Date) -lt $endTime) {
    $connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }
    foreach ($conn in $connections) {
        $results += [PSCustomObject]@{
            TimeStamp     = Get-Date
            LocalPort     = $conn.LocalPort
            RemoteAddress = $conn.RemoteAddress
            RemotePort    = $conn.RemotePort
            State         = $conn.State
        }
    }
    Start-Sleep -Seconds $interval
}

# Group and show unique remote ports
$results | Group-Object RemotePort | Sort-Object Name | Format-Table Name, Count