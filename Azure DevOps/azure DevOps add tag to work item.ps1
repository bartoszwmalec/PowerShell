#Authentication in Azure DevOps
$OrganizationName = "ae-mi-reporting"
$project = "PBI"
$AzureDevOpsPAT = "hykmv5p2urwuhfi6a4l4l6wnm2dei6frzqv5e6cpf7earfdxgcpa"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

# Paramters to set
$workItems = 1, 	2, 	3

$newTag = "super nowy tag"

Clear-Host

foreach ($workItemId in $workItems) {

$jsonBody = @"
[
    {
        "op": "add",
        "path": "/fields/System.Tags",
        "value": "$newTag"
    }
]
"@

$url = $("https://dev.azure.com/" + $organization + "/" + $project + "/" + "_apis/wit/workitems/" + $workItemId + "?api-version=6.0")


# Make the REST API call to update the work item
    try {
        $response = Invoke-RestMethod -Uri $url -Method Patch -Body $jsonBody -ContentType "application/json-patch+json" -Headers $AzureDevOpsAuthenicationHeader
        Write-Host $("Work item -" + $workItemId + "- has been updated.")
    } catch {
        Write-Host "Error updating work item parent: $_"
    }

}