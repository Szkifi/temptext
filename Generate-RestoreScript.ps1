# Generate-RestoreScript.ps1
param (
    [string]$MissingFile = "MissingInFile2.json",
    [string]$DiffFile = "Differences.json",
    [string]$OutScript = "Restore-ManagedProperties.ps1",
    [string]$SearchAppName = "Search Service Application"
)

$missing = @()
$diff = @()

if (Test-Path $MissingFile) {
    $missing = Get-Content -Raw -Path $MissingFile | ConvertFrom-Json
}
if (Test-Path $DiffFile) {
    $diff = Get-Content -Raw -Path $DiffFile | ConvertFrom-Json
}

$lines = @(
    "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue",
    "`$ssa = Get-SPEnterpriseSearchServiceApplication -Identity `"$SearchAppName`""
)

function CreatePropertyBlock($prop) {
    $block = @()
    $block += ""
    $block += "# Creating or updating property: $($prop.Name)"
    $block += "`$mp = New-SPEnterpriseSearchMetadataManagedProperty -SearchApplication `$ssa -Name `"$($prop.Name)`" -Type `"$($prop.ManagedType)`" -Queryable:$($prop.Queryable) -Retrievable:$($prop.Retrievable) -Refinable:$($prop.Refinable) -Sortable:$($prop.Sortable) -SafeForAnonymous:$($prop.SafeForAnonymous)"

    foreach ($map in $prop.Mappings) {
        $block += "`$cp = Get-SPEnterpriseSearchMetadataCrawledProperty -SearchApplication `$ssa -Category `"$($map.Category)`" | Where-Object { `$_.Name -eq `"$($map.Name)`" -and `$_.PropertySet -eq `"$($map.PropSet)`" }"
        $block += "if (`$cp) { New-SPEnterpriseSearchMetadataMapping -SearchApplication `$ssa -ManagedProperty `$mp -CrawledProperty `$cp }"
    }

    return $block
}

foreach ($prop in $missing + $diff) {
    $lines += CreatePropertyBlock $prop
}

$lines | Set-Content -Path $OutScript -Encoding UTF8
Write-Host "Generated import script: $OutScript"
