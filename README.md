# SortMP3
PowerShell script to move loose mp3 files to folders base on album names.

## Description:
This script includes two custom Functions, Get-MP3MetaData and Move-MP3ToFolder. [Thank you Prateek Singh for contributing Get-MP3MetaData](https://gist.github.com/PrateekKumarSingh/faafbfa53fcd753cf240f29deb769d87)

The script does the following when triggered:
1. gather meta data from mp3 files
2. for each mp3 file, look at the album name, and move to the folder with the same Album name
3. if such folder does not exist, create the folder (invalid windows filename charaters will be replaced), then move that mp3 to the folder
4. repeat until all mp3 files with the Album meta data are moved
  
## Direction:
Copy the PS1 to a folder containing mp3 files and run. You might need to set PowerShell execution policy to unrestricted.

## Restriction:
An mp3 file will not be processed if one of the following occurs:
1. it is missing the Album meta data
2. it is not in the same folder level as the script, i.e., already inside a child folder, no matter the folder match the album name or not

This script currently only support system whit display language set to Traditional Chinese, English and Japanese.
