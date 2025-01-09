# Define the CSV file path
$csvPath = "path/to/your/csvfile.csv"

# Function 1: Create the CSV file if it doesn't exist
function Ensure-CsvFile {
    if (-not (Test-Path -Path $csvPath)) {
        $headers = "created;id;filename;foldername;laststatus;downloaded;converted;html;iis1copy;iis2copy;tempdelete"
        $null = New-Item -ItemType File -Path $csvPath
        Set-Content -Path $csvPath -Value $headers -Encoding UTF8
        Write-Output "CSV file created."
    } else {
        Write-Output "CSV file already exists."
    }
}

# Function 2: Read the CSV and get items where tempdelete is 0
function Get-TempDeleteZeroItems {
    Import-Csv -Path $csvPath -Delimiter ';' | Where-Object { $_.tempdelete -eq "0" }
}

# Function 3: Add a new line with default values
function Add-NewCsvLine {
    param (
        [string]$filename,
        [string]$foldername
    )
    $newEntry = [PSCustomObject]@{
        created      = (Get-Date).ToString("o")
        id           = (Get-Random -Minimum 1 -Maximum 100000) # Generate a random ID
        filename     = $filename
        foldername   = $foldername
        laststatus   = (Get-Date).ToString("o")
        downloaded   = 0
        converted    = 0
        html         = 0
        iis1copy     = 0
        iis2copy     = 0
        tempdelete   = 0
    }
    $newEntry | Export-Csv -Path $csvPath -Delimiter ';' -Append -NoTypeInformation -Encoding UTF8
    Write-Output "New line added to CSV."
}

# Function 4: Search by foldername and return the ID for exact match
function Get-IdByFolderName {
    param (
        [string]$foldername
    )
    $entry = Import-Csv -Path $csvPath -Delimiter ';' | Where-Object { $_.foldername -eq $foldername }
    if ($entry) {
        return $entry.id
    } else {
        Write-Output "No matching foldername found."
    }
}

# Function 5: Modify a 0/1 column and update the laststatus
function Update-CsvColumn {
    param (
        [int]$id,
        [string]$column,
        [int]$value
    )
    $csvData = Import-Csv -Path $csvPath -Delimiter ';'
    foreach ($row in $csvData) {
        if ($row.id -eq $id) {
            $row.$column = $value
            $row.laststatus = (Get-Date).ToString("o")
        }
    }
    $csvData | Export-Csv -Path $csvPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
    Write-Output "Column updated for ID $id."
}

# Usage Examples
# Ensure the CSV file exists
Ensure-CsvFile

# Get items where tempdelete is 0
$tempDeleteZeroItems = Get-TempDeleteZeroItems
$tempDeleteZeroItems

# Add a new line to the CSV
Add-NewCsvLine -filename "example.txt" -foldername "exampleFolder"

# Search for an ID by foldername
$id = Get-IdByFolderName -foldername "exampleFolder"
Write-Output $id

# Update a column and modify the laststatus
Update-CsvColumn -id 1 -column "downloaded" -value 1
