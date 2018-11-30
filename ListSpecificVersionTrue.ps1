$SourcePath="C:\Dev\EnCompassCore\ActiveStable\src"
$LogPath="C:\Project\Scripts\GetSpecificVersion\Log2.txt"

$Items =Get-ChildItem -Path $SourcePath -Recurse | Where {$_.extension -like ".*proj"} | where {$_.extension -notlike ".vdproj"}
#$Items =Get-ChildItem -Path $SourcePath -Recurse -Include .*proj

 
 foreach($Item in $Items){

 try{

 $Path=$Item.DirectoryName

 $ContentPath="$Path\$Item"

 #$ContentPath ="C:\Project\Scripts\src\Services\ICEFixService\ICEFixService.vbproj"
 [xml]$Content=Get-Content -path $ContentPath  
 
 $ITEMS=$Content.Project.ItemGroup.Reference | Where-Object {$_.SpecificVersion -ne "False"}
 $Message="Project : $ContentPath `n"
 $Message | Out-File -FilePath $LogPath -Append
 $Items | Out-File -FilePath $LogPath -Append
 
 <#if($items -eq $null){

   #Write-Host "Specific version is false for the Project" $ContentPath
   "False: Specific Version for the Project: $ContentPath" | Out-File -FilePath $LogPath -Append
 }
 else{

  #Write-host "Specifiv version is true in Project $ContentPath and contents " $Items

   "True: Specific version for the Project: $ContentPath and Items are $Items"  | Out-File -FilePath $LogPath -Append
 }#>
  }
 catch{

    $Message ="Exception: Occured for path $ContentPath"+ $_.Exception
    $Message | Out-File -FilePath $LogPath -Append

 }

 }

