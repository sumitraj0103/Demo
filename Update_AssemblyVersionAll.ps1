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
[Parameter(mandatory=$true)][string]$BuildVersion

)

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
    [parameter(mandatory=$true)][string]$SourcePath,
    [Parameter(mandatory=$true)][string]$ProductVersion,
    [parameter(mandatory=$true)][string]$BuildVersion)


    try{


    $AllVersionFiles = Get-ChildItem $SourcePath AssemblyInfo.* -recurse
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

UpdateAssemblyInfoFiles $SourcePath $ProductVersion $BuildVersion