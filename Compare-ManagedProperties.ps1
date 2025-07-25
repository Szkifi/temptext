# Compare-ManagedProperties.ps1
param (
    [string]$File1,
    [string]$File2,
    [string]$MissingOutput = "MissingInFile2.xml",
    [string]$DiffOutput = "Differences.xml"
)

$props1 = Import-Clixml -Path $File1
$props2 = Import-Clixml -Path $File2

$missing = @()
$differences = @()

foreach ($p1 in $props1) {
    $p2 = $props2 | Where-Object { $_.Name -eq $p1.Name }

    if (-not $p2) {
        $missing += $p1
    }
    else {
        $changed = $false
        foreach ($prop in @("Type", "FullTextIndex", "Queryable", "Retrievable", "Refinable", "Sortable", "SafeForAnonymous", "TokenNormalization", "MappingCount")) {
            if ($p1.$prop -ne $p2.$prop) {
                $changed = $true
                break
            }
        }

        if ($changed) {
            $differences += $p1
        }
    }
}

if ($missing.Count -gt 0) {
    $missing | Export-Clixml -Path $MissingOutput
    Write-Host "Missing properties exported to $MissingOutput"
}
if ($differences.Count -gt 0) {
    $differences | Export-Clixml -Path $DiffOutput
    Write-Host "Differences exported to $DiffOutput"
}
