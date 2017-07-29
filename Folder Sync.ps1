################################################################################
#.SYNOPSIS
# Recursive file copy between two folders 
# creates missing subfolders and copies files if they don't exist in Destination.
#
#.DESCRIPTION
#  Recreate directory tree in destination and copy files over
#  If Dest has extra files, ignore.
#  Future To-Do - 
#      use hashing function to compare existing files.
# 
# 
#
#
#.LINK
# https://github.com/bobbrazeau/
#
################################################################################
Clear-Host
$SourcePath = "C:\temp"
$DestPath   = "C:\temp2"
$logFile = "C:\temp\synclog.txt"
$tempPath = ""
$tempFile = ""
$runType = "normal"
$maxFiles = 3
$fileCount = 0

#Grab folder and file info at same time so they are in sync
$folderList = Get-ChildItem $SourcePath  -directory -recurse
$fileList = Get-ChildItem $SourcePath  -file -recurse

#if logFile is set, check for existance and create if necessary
if ($logFile -ne "") {
    if (-Not (Test-Path $logFile)){
        New-Item $logFile -type file
    }
    $d = Get-Date -Format g
    $msg = "Starting sync run at " + $d
    Add-Content $logFile $msg
}

#Create the folder structure in Dest to match Source
foreach($dir in $folderList){
    $tempPath = $DestPath + $dir.fullname.replace($SourcePath,"")
    if (-Not (Test-Path $tempPath)) {
        $msg = "Create folder - " + $tempPath 
        if ($runType -eq "output"){
            $msg
        } else {
            New-Item $tempPath -type directory | out-null;
            if ($logFile -ne "" -And (Test-Path $logFile)){
                Add-Content $logFile  $msg
            }
        }
    }
}

#Run through the files and copy if there isn't an exact name match.
foreach($file in $fileList){
    $tempFile =  $DestPath + $File.fullname.replace($SourcePath,"")

    #ensure there isn't a dest copy of the file and source still exits
    if (-Not (Test-Path $tempFile) -And ( Test-Path $file.fullName)) {
        $msg =  "Copy " + $file.fullname + " To " + $tempFile
        if ($runType -eq "output"){
            $msg
        } else {
            if ($fileCount -ge $maxFiles){
                Break
            } else {
                $fileCount = $fileCount +1
                Copy-Item $file.fullname $tempFile | out-null;
                if ($logFile -ne "" -And (Test-Path $logFile)){
                    Add-Content $logFile $msg
                }
            }
        }
    }
}
if ($fileCount -eq 0){
    if ($logFile -ne "" -And (Test-Path $logFile)){
        Add-Content $logFile "No files transfered"
    }
}
