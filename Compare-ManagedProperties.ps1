# Compare-ManagedProperties.ps1
param (
    [string]$File1,
    [string]$File2,
    [string]$MissingOutput = "MissingInFile2.json",
    [string]$DiffOutput = "Differences.json"
)

$props1 = Get-Content -Raw -Path $File1 | ConvertFrom-Json
$props2 = Get-Content -Raw -Path $File2 | ConvertFrom-Json

$missing = @()
$differences = @()

foreach ($p1 in $props1) {
    $p2 = $props2 | Where-Object { $_.Name -eq $p1.Name }

    if (-not $p2) {
        $missing += $p1
    }
    else {
        $changed = $false
        foreach ($prop in @("ManagedType", "FullTextIndex", "Queryable", "Retrievable", "Refinable", "Sortable", "SafeForAnonymous", "TokenNormalization")) {
            if ($p1.$prop -ne $p2.$prop) {
                $changed = $true
                break
            }
        }

        # Compare mapping count
        if ($p1.Mappings.Count -ne $p2.Mappings.Count) {
            $changed = $true
        }

        if ($changed) {
            $differences += $p1
        }
    }
}

if ($missing.Count -gt 0) {
    $missing | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $MissingOutput
    Write-Host "Missing properties exported to $MissingOutput"
}
if ($differences.Count -gt 0) {
    $differences | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $DiffOutput
    Write-Host "Differing properties exported to $DiffOutput"
}
