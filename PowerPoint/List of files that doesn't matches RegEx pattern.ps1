Clear-Host
# Define the directory to search
$directoryPath = "C:\Users\a767818\Eviden\WFM GDC PL - Bench_CVs"

# Define the regex pattern
$pattern = '_[a-zA-Z]{1,2}\d{6}\.pptx$'

# Get all files in the directory and filter those not matching the pattern
$filesNotMatching = Get-ChildItem -Path $directoryPath -File | Where-Object { <#-not#> ($_.Name -match $pattern) }

#$filesNotMatching

# Create a new List of integers
$list = New-Object System.Collections.Generic.List[string]

$filesNotMatching | Select-Object @{Name='DASID'; Expression={$_.Name.Split("_")[-1].Replace(".pptx","")}} | Select-Object 'DASID' | ForEach-Object { $list.Add($_) }

$list = $filesNotMatching | Select-Object @{Name='DASID'; Expression={$_.Name.Split("_")[-1].Replace(".pptx","")}} | Select-Object 'DASID' 

$list

# Add items from the array to the list
#$filesNotMatching | ForEach-Object { $list.Add($_) }

# Output the list


<#
# Output the list of files not matching the regex
$filesNotMatching | Select-Object @{ name='DAS ID', $_.Name.split("_")[-1]}  #, FullName
#>

