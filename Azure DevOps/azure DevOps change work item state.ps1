$project = "PBI"

#Authentication in Azure DevOps
$AzureDevOpsPAT = "hykmv5p2urwuhfi6a4l4l6wnm2dei6frzqv5e6cpf7earfdxgcpa"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$OrganizationName = "ae-mi-reporting"


#Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 

# Define the REST API URL for updating the work item
#Power app premium plan 
$workItemsList = 7, 	8, 	10, 	12, 	13, 	14, 	15, 	16, 	17, 	18, 	19, 	20, 	21, 	22, 	23, 	24, 	25, 	26, 	27, 	28, 	29, 	30, 	31, 	32, 	33, 	34, 	36, 	40, 	41, 	42, 	43, 	53, 	54, 	55, 	56, 	57, 	58, 	59, 	60, 	61, 	62, 	63, 	64, 	65, 	66, 	67, 	68, 	69, 	70, 	71, 	72, 	73, 	74, 	75, 	76, 	77, 	78, 	79, 	90
$NewState = "Active"

Clear-Host

foreach ($workItemId in $workItemsList) {

$jsonBody = @"
[
  {
    "op": "replace",
    "path": "/fields/System.State",
    "value": "$NewState"
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