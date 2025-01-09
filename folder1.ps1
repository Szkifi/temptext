function Sanitize-FolderName {
    param (
        [string]$InputString
    )

    # Map special characters to standard English letters
    $charMap = @{
        'á' = 'a'; 'à' = 'a'; 'â' = 'a'; 'ä' = 'a'; 'ã' = 'a'; 'å' = 'a';
        'é' = 'e'; 'è' = 'e'; 'ê' = 'e'; 'ë' = 'e';
        'í' = 'i'; 'ì' = 'i'; 'î' = 'i'; 'ï' = 'i';
        'ó' = 'o'; 'ò' = 'o'; 'ô' = 'o'; 'ö' = 'o'; 'õ' = 'o'; 'ø' = 'o';
        'ú' = 'u'; 'ù' = 'u'; 'û' = 'u'; 'ü' = 'u';
        'ç' = 'c'; 'ñ' = 'n';
        'ý' = 'y'; 'ÿ' = 'y';
    }

    # Replace special characters using the map
    foreach ($key in $charMap.Keys) {
        $InputString = $InputString -replace [regex]::Escape($key), $charMap[$key]
    }

    # Replace spaces with underscores
    $InputString = $InputString -replace ' ', '_'

    # Remove characters that are invalid in Windows folder names
    $InputString = $InputString -replace '[<>:"/\\|?*]', ''

    # Trim trailing dots and spaces (invalid in Windows folder names)
    $InputString = $InputString.TrimEnd('.')
    $InputString = $InputString.TrimEnd(' ')

    # List of forbidden Windows folder names
    $forbiddenNames = @(
        'CON', 'PRN', 'AUX', 'NUL',
        'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
        'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    )

    # Check if the sanitized name is a forbidden folder name
    if ($forbiddenNames -contains $InputString.ToUpper()) {
        return $false
    }

    # Return the sanitized string
    return $InputString
}

# Example usage
$folderName = "áFolder Name<>|/\\"
$sanitizedFolderName = Sanitize-FolderName -InputString $folderName
if ($sanitizedFolderName -eq $false) {
    Write-Host "The folder name is forbidden."
} else {
    Write-Host "Sanitized folder name: $sanitizedFolderName"
}
