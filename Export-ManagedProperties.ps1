# Export-ManagedProperties.ps1
param (
    [string]$OutputFile = "ManagedProperties_$(Get-Date -Format yyyyMMdd_HHmmss).json",
    [string]$SearchAppName = "Search Service Application"
)

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$ssa = Get-SPEnterpriseSearchServiceApplication -Identity $SearchAppName
$managedProps = Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa
$allMappings = Get-SPEnterpriseSearchMetadataMapping -SearchApplication $ssa

# Index managed properties by their ManagedPid for fast lookup
$mpIndex = @{}
foreach ($mp in $managedProps) {
    $mpIndex[$mp.PID] = $mp
}

$export = @()

foreach ($mp in $managedProps) {
    $pid = $mp.PID
    $mappings = $allMappings | Where-Object {
        $_.ManagedPid -eq $pid
    } | ForEach-Object {
        @{
            Name     = $_.CrawledPropertyName
            Category = $_.CrawledCategory
            PropSet  = $_.CrawledPropertySet
        }
    }

    $export += [PSCustomObject]@{
        Name = $mp.Name
        ManagedType = if ($mp.ManagedType) { $mp.ManagedType.ToString() } else { "Unknown" }
        FullTextIndex = $mp.FullTextIndex
        Queryable = $mp.Queryable
        Retrievable = $mp.Retrievable
        Refinable = $mp.Refinable
        Sortable = $mp.Sortable
        SafeForAnonymous = $mp.SafeForAnonymous
        TokenNormalization = $mp.TokenNormalization
        Mappings = $mappings
    }
}

$export | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $OutputFile
Write-Host "Export completed to $OutputFile"
