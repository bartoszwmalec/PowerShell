<#
cls
$path = "C:\Users\a767818\Eviden\WFM GDC PL - Bench_CVs"
cd $path

$extensions = @("pdf", "pptx", "potx")
Get-ChildItem -Path $path -File | Where-Object { $extensions -contains $_.Extension.TrimStart('.') } | Select-Object Name
#>


# Define the path to the CSV file and the folder containing the files
$csvPath = "C:\Path\To\Your\File.csv"  # Change this to your CSV file path
$folderPath = "C:\Users\a767818\Eviden\WFM GDC PL - Bench_CVs"  # Change this to your target folder path

# Import the CSV file
$fileMappings = Import-Csv -Path $csvPath

# Loop through each mapping in the CSV
foreach ($mapping in $fileMappings) {
    $oldFileName = $mapping.Old
    $newFileName = $mapping.New

    # Construct the full path for the old and new file names
    $oldFilePath = Join-Path -Path $folderPath -ChildPath $oldFileName
    $newFilePath = Join-Path -Path $folderPath -ChildPath $newFileName

    # Check if the old file exists
    if (Test-Path -Path $oldFilePath) {
        # Rename the file
        Rename-Item -Path $oldFilePath -NewName $newFileName
        Write-Host "Renamed '$oldFileName' to '$newFileName'"
    } else {
        Write-Host "File '$oldFileName' not found in '$folderPath'"
    }
}