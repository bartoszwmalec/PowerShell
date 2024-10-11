# Define the directory containing the files
Clear-Host
# Define the directory to search
$sourceDirectory = "C:\Users\a767818\Eviden\WFM GDC PL - Bench_CVs"

# Define the target directory (Archive subfolder)
$archiveDirectory = Join-Path -Path $sourceDirectory -ChildPath "Archive"

# Create the Archive directory if it doesn't exist
if (-not (Test-Path -Path $archiveDirectory)) {
    New-Item -ItemType Directory -Path $archiveDirectory
}

# Define the list of file names to match
$list = @("A678806",
"A701885",
"A828009",
"A692610",
"A687997",
"A772525",
"A912295",
"A408103",
"A681934",
"A514505",
"A910839",
"A687993",
"A687994",
"A804651",
"A874681",
"A875212",
"A691976",
"A855522",
"A832537",
"A828062",
"A794788",
"A769033",
"A884234",
"A763506",
"A911360",
"A887514",
"A660487",
"A797402",
"A669896",
"A832134",
"A906271",
"A905194",
"A892246",
"A851592") # Add your file names here

# Get all files in the source directory
$files = Get-ChildItem -Path $sourceDirectory -File

# Loop through each file and check if its name matches any item in the list
  foreach ($item in $list) {
    foreach ($file in $files) {
        if ($file.Name -like "*$item*") {
            # Move the file to the Archive directory
            Move-Item -Path $file.FullName -Destination $archiveDirectory
            Write-Output "Moved: $($file.Name) to Archive"
        }
    }
}