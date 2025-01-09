# Set variables
$siteUrl = "https://your-sharepoint-site-url"  # Replace with your SharePoint site URL
$listName = "YourListName"  # Replace with the name of your list

# Get the access token using the running user's credentials
$headers = @{ "Authorization" = "Bearer $($env:ACCESS_TOKEN)" }

# Function to create a new list item
function Create-ListItem {
    param (
        [string]$Title,  # Replace with the columns you want to fill
        [hashtable]$AdditionalFields
    )

    $endpointUrl = "$siteUrl/_api/web/lists/getbytitle('$listName')/items"
    $headers["Accept"] = "application/json;odata=verbose"
    $headers["Content-Type"] = "application/json;odata=verbose"
    $headers["X-RequestDigest"] = (Invoke-RestMethod -Uri "$siteUrl/_api/contextinfo" -Method POST -Headers $headers).d.GetContextWebInformation.FormDigestValue

    $itemProperties = @{
        "Title" = $Title
    } + $AdditionalFields

    $jsonBody = $itemProperties | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $endpointUrl -Method POST -Headers $headers -Body $jsonBody
        Write-Host "Item successfully created with ID: $($response.d.Id)"
    } catch {
        Write-Error "Error creating item: $_"
    }
}

# Function to update a field in a list item
function Update-ListItem {
    param (
        [int]$ItemId,
        [hashtable]$FieldsToUpdate
    )

    $endpointUrl = "$siteUrl/_api/web/lists/getbytitle('$listName')/items($ItemId)"
    $headers["Accept"] = "application/json;odata=verbose"
    $headers["Content-Type"] = "application/json;odata=verbose"
    $headers["X-RequestDigest"] = (Invoke-RestMethod -Uri "$siteUrl/_api/contextinfo" -Method POST -Headers $headers).d.GetContextWebInformation.FormDigestValue
    $headers["IF-MATCH"] = "*"

    $jsonBody = $FieldsToUpdate | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $endpointUrl -Method MERGE -Headers $headers -Body $jsonBody
        Write-Host "Item with ID $ItemId successfully updated."
    } catch {
        Write-Error "Error updating item: $_"
    }
}

# Function to search for a list item by field value
function Search-ListItem {
    param (
        [string]$FieldName,
        [string]$FieldValue
    )

    $endpointUrl = "$siteUrl/_api/web/lists/getbytitle('$listName')/items?\$filter=$FieldName eq '$FieldValue'"
    $headers["Accept"] = "application/json;odata=verbose"

    try {
        $response = Invoke-RestMethod -Uri $endpointUrl -Method GET -Headers $headers
        if ($response.d.results.Count -gt 0) {
            Write-Host "Found items:" ($response.d.results | ConvertTo-Json -Depth 10)
        } else {
            Write-Host "No items found with $FieldName equal to '$FieldValue'."
        }
    } catch {
        Write-Error "Error searching for item: $_"
    }
}

# Example usage
# Create-ListItem -Title "New Item" -AdditionalFields @{ "CustomField" = "CustomValue" }
# Update-ListItem -ItemId 1 -FieldsToUpdate @{ "Title" = "Updated Title" }
# Search-ListItem -FieldName "Title" -FieldValue "Updated Title"
