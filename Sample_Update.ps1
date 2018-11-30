#################################################
#
#Update the Assembly for the updated Version
#
#
#################################################
function UpdateAssemblyinfo{
param(
[parameter(mandatory=$true)][string]$Path,
[Parameter(mandatory=$true)][string]$ProductVersion,
[parameter(mandatory=$true)][string]$FileVersion)


    try{


    $AllVersionFiles = Get-ChildItem $Path AssemblyInfo.* -recurse
    #$assemblyVersion=GetAssemblyNumber $BuildXmlPath
    #$assemblyFileVersion=GetFileVersion $BuildXmlPath

    #if(($assemblyVersion -ne $null) -and ($assemblyFileVersion -ne $null)){

    foreach ($file in $AllVersionFiles) 
    { 
        (Get-Content $file.FullName) |
        %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyVersion(""$ProductVersion"")" } |
        %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyFileVersion(""$FileVersion"")" } |
        #%{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}."\)', "AssemblyFileVersion(""$assemblyFileVersion"")" } |
	    Set-Content $file.FullName -Force

        Write-Verbose -Verbose "the File Update with version"
        $BuildVersion
        $file
    }


    #}
    #else{

    #Write-Verbose -Verbose "Assembly Version or AssemblyFileVersion is not correct"

    #}

    }
    catch{

   
    write-host "Exception occured during the Assembly version update" $_Exception


    }
    

}

$GETApp=gci -path "C:\Project\Scripts\src" -Directory

$GETApp.Name

$SRC_RootPath="C:\Project\Scripts\src"
$Date="20181026"
foreach($ProjectName in $GETApp){


   $UpdatedProject=Get-ChildItem -path "$SRC_RootPath\$ProjectName" -Recurse | Where-Object {$_.LastWriteTime.ToString("yyyyMMdd") -ge $Date}
   $UpdatedProject
   if($UpdatedProject){

   foreach($SubProject in $UpdatedProject.DirectoryName){

    if((get-item "$SubProject") -is [System.IO.DirectoryInfo]){

      write-host "i am in subproject " $SubProject
      UpdateAssemblyinfo $SubProject "8.5.9" "8.5.9.10"
    }
    else{

    write-host "File no need to update "$SubProject
    }
   #write-host "i am in subproject " $SubProject
   #UpdateAssembly $

   }

   }
   else{

   Write-host "thee is nothing to update"
   }
}

