$project = "PBI"

#Authentication in Azure DevOps
$AzureDevOpsPAT = "hykmv5p2urwuhfi6a4l4l6wnm2dei6frzqv5e6cpf7earfdxgcpa"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

$OrganizationName = "ae-mi-reporting"
$UriOrganization = "https://dev.azure.com/$($OrganizationName)/"

#Lists all projects in your organization
$uriAccount = $UriOrganization + "_apis/projects?api-version=5.1"
Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 



# Define the REST API URL for updating the work item

#Power app premium plan 
$workItems = 1, 	4, 	5, 	6, 	7, 	8, 	9, 	10, 	11, 	12, 	13, 	14, 	16, 	27, 	37, 	38, 	39, 	40, 	41, 	42, 	43, 	44, 	45, 	46, 	47, 	48, 	49, 	50, 	51, 	52, 	53, 	54, 	55, 	56, 	57, 	58, 	59, 	60, 	61, 	62, 	63, 	64, 	65, 	66, 	67, 	68, 	69, 	70, 	71, 	72, 	73, 	74, 	75, 	76, 	77, 	78, 	79, 	80, 	81, 	82, 	83, 	84, 	85, 	86, 	87, 	88, 	89, 	90



# Iterate through each work item ID in the list
foreach ($workItemId in $workItems) {
    $url = $("https://dev.azure.com/" + $organization + "/" + $project + "/" + "_apis/wit/workitems/" + $workItemId + "?api-version=6.0")

    print($url)

    # Define the JSON body to update the work item type
$jsonBody = @"
[
    {
        `"op`": `"add`",
        `"path`": `"/fields/System.WorkItemType`",
        `"value`": `"Feature`"
    }
]
"@

        # Make the REST API call to update the work item
    Invoke-RestMethod -Uri $url -Method Patch -Body $jsonBody -ContentType "application/json-patch+json" -Headers $AzureDevOpsAuthenicationHeader

}


