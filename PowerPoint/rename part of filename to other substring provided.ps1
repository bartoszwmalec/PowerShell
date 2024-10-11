# input parameters
$folderPath = "C:\Users\a767818\Eviden\WFM GDC PL - Bench_CVs"
$stringToBeReplaced = "_."
$stringThatReplaces = "."

Get-ChildItem -Path $folderPath -File | ForEach-Object {
    if ($_.Name -like $("*" + $stringToBeReplaced + "*") ) {
        $newName = $_.Name -replace $stringToBeReplaced, $stringThatReplaces
        # Rename the file
        Rename-Item -Path $_.FullName -NewName $newName -Verbose
    }
}