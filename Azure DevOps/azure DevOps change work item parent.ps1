$project = "PBI"


#Authentication in Azure DevOps
$AzureDevOpsPAT = "hykmv5p2urwuhfi6a4l4l6wnm2dei6frzqv5e6cpf7earfdxgcpa"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

$OrganizationName = "ae-mi-reporting"
$UriOrganization = "https://dev.azure.com/$($OrganizationName)/"

#Lists all projects in your organization
$uriAccount = $UriOrganization + "_apis/projects?api-version=5.1"
Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 
$parentId = 105


# Define the REST API URL for updating the work item

#Power app premium plan 
$workItems = 1, 	2, 	3, 	33, 	34, 	35, 	37, 	38, 	39, 	44, 	45, 	46, 	47, 	48, 	49, 	50, 	51, 	52, 	55, 	56, 	57, 	58, 	59, 	60, 	61, 	62, 	63, 	64, 	65, 	66, 	67, 	68, 	69, 	70, 	71, 	72, 	73, 	74, 	75, 	76, 	77, 	78, 	79, 	80, 	81, 	82, 	83, 	84, 	85, 	86, 	87, 	88, 	89


Clear-Host


foreach ($workItemId in $workItems) {

$jsonBody = @"
[
    {
        "op": "add",
        "path": "/relations/-",
        "value": {
            "rel": "System.LinkTypes.Hierarchy-Reverse",
            "url": "https://dev.azure.com/$organization/$project/_apis/wit/workitems/$parentId"
        }
    }
]
"@
$url = "https://dev.azure.com/$organization/$project/_apis/wit/workitems/$workItemId`?api-version=6.0"
# Make the REST API call to update the work item
    try {
        $response = Invoke-RestMethod -Uri $url -Method Patch -Body $jsonBody -ContentType "application/json-patch+json" -Headers $AzureDevOpsAuthenicationHeader
        Write-Host $("Work item -" + $workItemId + "- has new parent assigned: " + $parentId)
    } catch {
        Write-Host "Error updating work item parent: $_"
    }

}