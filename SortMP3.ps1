Function Get-MP3MetaData
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Psobject])]
    Param
    (
        [String] [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $Directory
    )

    Begin
    {
        $shell = New-Object -ComObject "Shell.Application"
    }
    Process
    {

        Foreach($Dir in $Directory)
        {
            $ObjDir = $shell.NameSpace($Dir)
            $Files = gci $Dir| ?{$_.Extension -in '.mp3','.mp4'}

            Foreach($File in $Files)
            {
                $ObjFile = $ObjDir.parsename($File.Name)
                $MetaData = @{}
                $MP3 = ($ObjDir.Items()|?{$_.path -like "*.mp3" -or $_.path -like "*.mp4"})
                $PropertArray = 0,1,2,12,13,14,15,16,17,18,19,20,21,22,27,28,36,220,223
            
                Foreach($item in $PropertArray)
                { 
                    If($ObjDir.GetDetailsOf($ObjFile, $item)) #To avoid empty values
                    {
                        $MetaData[$($ObjDir.GetDetailsOf($MP3,$item))] = $ObjDir.GetDetailsOf($ObjFile, $item)
                    }
                 
                }
            
                New-Object psobject -Property $MetaData |select *, @{n="Directory";e={$Dir}}, @{n="Fullname";e={Join-Path $Dir $File.Name -Resolve}}, @{n="Extension";e={$File.Extension}}
            }
        }
    }
    End
    {
    }
}

Function Move-Mp3ToFolder 
{
    [CmdletBinding()]
    Param
    (
        [String] [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $Directory
    )

    Set-Location $Directory

    switch -Wildcard ((Get-ItemProperty 'HKCU:\Control Panel\Desktop' PreferredUILanguages).PreferredUILanguages[0])
    {
        "en*" {$albumname = "Album"}
        "zh*" {$albumname = "專輯"}
        default {$albumname = $null}    #to make sure no lagecy value
    }

    if ($null -ne $albumname) {
        ForEach($mp3 in (Get-MP3MetaData -Directory $Directory)){
            $Source = $mp3.Fullname
            $Album = $mp3.$albumname -replace '[\\/:*?"<>|]','_'    #replace invalid windows filename charaters
                                                                    #every single charaters inside the square brackets are replaced individually, instead of treated as a whole string
                                                                    #backslash is n escape charater, need to double it in order to tread it as string
            If(-not (Get-ChildItem | ?{$_.name -eq $Album -and $_.PSisContainer}))
            {
                New-Item -Name $Album -ItemType Directory -Force | Out-Null
            }
            Move-Item -Path  $Source -Destination "$Directory\$album" -Force
        }  
        Read-Host "All action completed, press any key to exit"      
    } else 
    {
        Read-Host "System language is not supported, press any key to exit"    
    }
}

Get-Location | Move-Mp3ToFolder
