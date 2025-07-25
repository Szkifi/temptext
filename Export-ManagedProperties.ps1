# Export-ManagedProperties.ps1
param (
    [string]$OutputFile = "ManagedProperties_$(Get-Date -Format yyyyMMdd_HHmmss).xml",
    [string]$SearchAppName = "Search Service Application"
)

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$ssa = Get-SPEnterpriseSearchServiceApplication -Identity $SearchAppName
$schema = Get-SPEnterpriseSearchSchema -SearchApplication $ssa

$managedProps = Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa

$export = @()

foreach ($mp in $managedProps) {
    $mappings = $mp.CrawledProperties |
        ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Category = $_.CategoryName
                PropSet = $_.PropertySet
            }
        }

    $export += [PSCustomObject]@{
        Name = $mp.Name
        Type = $mp.Type
        FullTextIndex = $mp.FullTextIndex
        Queryable = $mp.Queryable
        Retrievable = $mp.Retrievable
        Refinable = $mp.Refinable
        Sortable = $mp.Sortable
        SafeForAnonymous = $mp.SafeForAnonymous
        TokenNormalization = $mp.TokenNormalization
        MappingCount = $mappings.Count
        Mappings = $mappings
    }
}

$export | Export-Clixml -Path $OutputFile
Write-Host "Export completed to $OutputFile"
