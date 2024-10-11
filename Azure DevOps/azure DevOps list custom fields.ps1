$OrganizationName = "ae-mi-reporting"
$project = "PBI"
$AzureDevOpsPAT = "hykmv5p2urwuhfi6a4l4l6wnm2dei6frzqv5e6cpf7earfdxgcpa"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

#Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 
# Step 1: Get the list of processes
$processesUrl = "https://dev.azure.com/$organization/_apis/work/processes?api-version=6.0"
$processes = Invoke-RestMethod -Uri $processesUrl -Method Get -Headers $AzureDevOpsAuthenicationHeader 


# Split the input string into individual objects
$objects = $processes -split "`n" | ForEach-Object { Invoke-Expression $_ }

# Create an array to hold the results
$result = @()

# Iterate through each object and extract typeId and name
foreach ($obj in $objects) {
    $result += [PSCustomObject]@{
        Id   = $obj.typeId
        Name = $obj.name
    }
}

# Output the results
$result | Format-Table -AutoSize

foreach ($process in $processesZ) {
    Write-Host $process.value #"Custom Field: $($field.name), Reference Name: $($field.referenceName)"
}


#####################
<#



# Assuming you want to use the first process found
$processId = $processes.value[0].id  # Adjust as necessary if you have multiple processes

# Step 2: Get fields for the Epic work item type
$fieldsUrl = "https://dev.azure.com/$organization/_apis/work/processes/$processId/workItemTypes/Epic/fields?api-version=6.0"
$fields = Invoke-RestMethod -Uri $fieldsUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

# Step 3: Filter and display custom fields
$customFields = $fields.value | Where-Object { $_.isCustom -eq $true }

foreach ($field in $customFields) {
    Write-Host "Custom Field: $($field.name), Reference Name: $($field.referenceName)"
}

#>

break

$url = "https://dev.azure.com/$organization/$project/_apis/wit/fields?api-version=6.0"

try {
    $fields = Invoke-RestMethod -Uri $url -Method Get -Headers $AzureDevOpsAuthenicationHeader
    
    # Filter the fields to get only the custom fields
    $customFields = $fields.value | Where-Object { $_.name -like "Custom.*" }
    
    # Print the custom field names
    foreach ($field in $customFields) {
        Write-Host "Custom Field: $($field.name)"
    }
} catch {
    Write-Host "Error getting fields: $_"
}
