# Export-ManagedProperties.ps1
param (
    [string]$OutputFile = "ManagedProperties_$(Get-Date -Format yyyyMMdd_HHmmss).xml",
    [string]$SearchAppName = "Search Service Application"
)

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$ssa = Get-SPEnterpriseSearchServiceApplication -Identity $SearchAppName
$managedProps = Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa
$allMappings = Get-SPEnterpriseSearchMetadataMapping -SearchApplication $ssa

$export = @()

foreach ($mp in $managedProps) {
    $mappings = $allMappings | Where-Object {
        $_.ManagedPropertyName -eq $mp.Name
    } | ForEach-Object {
        [PSCustomObject]@{
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

$export | Export-Clixml -Path $OutputFile
Write-Host "Export completed to $OutputFile"
