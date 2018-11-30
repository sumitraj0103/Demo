#######################################################################################
#
#
# This script is used to get the Build number frm XML generate new build number
# and create Aseembly version and File Version
#
# Before the Compilation it increment the build number and save the latest build number
#
#######################################################################################


#$BuildXmlPath="C:\Dev\EnCompassCore\Active\BuildVersion.xml"


param(
[Parameter(mandatory=$true)][string]$SourcePath,
[Parameter(mandatory=$true)][string]$ProductVersion,
[Parameter(mandatory=$true)][string]$BuildVersion,
[Parameter(mandatory=$true)][String]$LogP,
[String]$Date
)

$ScriptRootPath="D:\Scripts"
$LogFile="AssemblyInfoUpdate_"+(Get-Date).ToString("dd-MM-yyyy")+".txt"

# For creating the Log file with timestamp
if(Test-path -path "$LogP\$LogFile"){

    write-host "LogFileExist"

}
else{

    New-Item -Path $LogP -Name $LogFile -ItemType "file"

}

# Real time for Logging
function GetRealtime{


  $date=(get-date).ToString("dd-MM-yyyy:hh:mm:ss")
  return $date

 }

$Global:Date

#Getting the current date for copying the Files
if($Date -eq ''){

$Global:Date=(Get-Date).ToString("yyyyMMdd")

}
else{

# For specific date, from the Parameter
$Global:Date=$Date

}

function GetFileVersion{

Param(
    [Parameter(mandatory=$true)][string]$XmlPath)

    try{

    [xml]$BuildDetail=Get-content -path $BuildXmlPath
    $majorVersion=$BuildDetail.Configuration.MajorVersion
    $minorVersion=$BuildDetail.Configuration.minorVersion
    $patch=$BuildDetail.Configuration.PatchVersion
    [int]$buildNumber=$BuildDetail.Configuration.BuildNumber
    $Build_Number=$buildNumber+1
    $BuildFileVersion=$majorVersion+'.'+$minorVersion+'.'+$patch+'.'+ $Build_Number

    return $BuildFileVersion
    }
    catch{

    Write-host "Exception occured to get the  BuildFileVersion" $_Exception
    return $null


    }
}
function GetAssemblyNumber{

Param(
    [Parameter(mandatory=$true)][string]$XmlPath)

    try{

    [xml]$BuildDetail=Get-content -path $BuildXmlPath
    $majorVersion=$BuildDetail.Configuration.MajorVersion
    $minorVersion=$BuildDetail.Configuration.minorVersion
    $patch=$BuildDetail.Configuration.PatchVersion
    [int]$buildNumber=$BuildDetail.Configuration.BuildNumber
    $Build_Number=$buildNumber+1
    $BuildAssemblyVersion=$majorVersion+'.'+$minorVersion+'.'+$patch

    return $BuildAssemblyVersion
    }
    catch{

    Write-host "Exception occured to get the  BuildAssemblyVersion" $_Exception
    return $null

    }
}

function UpdateBuildNumber{

Param(
    [Parameter(mandatory=$true)][string]$XmlPath)

    try{
    [xml]$BuildDetail=Get-content -path $BuildXmlPath
    [int]$buildNumber=$BuildDetail.Configuration.BuildNumber
    [string]$Build_Number=$buildNumber+1
    $BuildDetail.Configuration.BuildNumber=$Build_Number
    $BuildDetail.Save($BuildXmlPath)
    }
    catch{

    Write-host "Exception occured during the Build number Update" $_Exception

    }

}

function UpdateAssemblyInfoFiles{
param(
    [parameter(mandatory=$true)][string]$SPPath,
    [Parameter(mandatory=$true)][string]$ProductVersion,
    [parameter(mandatory=$true)][string]$BuildVersion)


    try{


    $AllVersionFiles = Get-ChildItem $SPPath AssemblyInfo.* -recurse
    #$assemblyVersion=GetAssemblyNumber $BuildXmlPath
    #$assemblyFileVersion=GetFileVersion $BuildXmlPath

    #if(($assemblyVersion -ne $null) -and ($assemblyFileVersion -ne $null)){

    foreach ($file in $AllVersionFiles) 
    { 
        (Get-Content $file.FullName) |
        %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyVersion(""$ProductVersion"")" } |
        %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyFileVersion(""$BuildVersion"")" } |
        #%{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}."\)', "AssemblyFileVersion(""$assemblyFileVersion"")" } |
	    Set-Content $file.FullName -Force
        $time=GetRealtime
        "`n $time Info: Assembly Info Update $SPPath :: $file : Version $BuildVersion " | out-file -FilePath $LogP\$LogFile -Append
        #Write-Verbose -Verbose "the File Update with version"
        #$BuildVersion
        #$file
    }


    #}
    #else{

    #Write-Verbose -Verbose "Assembly Version or AssemblyFileVersion is not correct"

    #}

    }
    catch{
    $time=GetRealtime
    $Message="Exception: Occured during the Assemblyinfo Update "+$_.Exception
    "`n $time $Message" | out-file -FilePath $LogP\$LogFile -Append
   
    #write-host "Exception occured during the Assembly version update" $_Exception


    }
    
}

#UpdateAssemblyInfoFiles $SourcePath $ProductVersion $BuildVersion



##############################################################
#
#
#Updating the Assembly Info for Updated Project
#
#
###############################################################

try{

$GETApps=gci -path $SourcePath -Directory
#$GETApp.Name
#$Date="20181026"
foreach($ProjectName in $GETApps){

   $UpdatedProject=Get-ChildItem -path "$SourcePath\$ProjectName" -Recurse | Where-Object {$_.LastWriteTime.ToString("yyyyMMdd") -ge $Global:Date}
   $UpdatedProject
   if($UpdatedProject){

   foreach($SubProject in $UpdatedProject.DirectoryName){

    if((get-item "$SubProject") -is [System.IO.DirectoryInfo]){

      write-host "i am in subproject " $SubProject
      UpdateAssemblyinfoFiles $SubProject $ProductVersion $BuildVersion
    }
    else{

    write-host "File no need to update "$SubProject
    }
   #write-host "i am in subproject " $SubProject
   #UpdateAssembly $

   }

   }
   else{
   $time=GetRealtime
   "`n $time Info: Skipping the Project::$ProjectName for Version Update as there is no change in current build " | out-file -FilePath $LogP\$LogFile -Append
   }
}
}
catch{

 $time=GetRealtime
 $Message="Exception: Occured during the Assemblyinfo Update "+$_.Exception
 "`n $time $Message" | out-file -FilePath $LogP\$LogFile -Append
}

