<#
	PSDataReorg Setup: install the necessary for DataReorg_PDF.ps1
	----------------------------------------------------------------------------------------------------------------
	Author:				GSolone
	Version:			0.1
	Usage:				.\DataReorg_Setup.ps1
	Info:				https://gioxx.org/tag/psdatareorg
	Last update:		25-10-2020
	Credits:			https://github.com/jourdant/powershell-paperless/
	Updates:
		0.1- first public version, hello GitHub!
#>

<# PLEASE:
	- READ the Readme file to know how you can use this script.
#>

#properties
#================================================================
$itextsharp_url = "https://nuget.org/api/v2/package/iTextSharp"
$BouncyCastle_url = "https://nuget.org/api/v2/package/BouncyCastle"
$itextsharp_zip_name = "$PSScriptRoot\itextsharp.zip"
$BouncyCastle_zip_name = "$PSScriptRoot\BouncyCastle.zip"
$lib_dir_name = "$PSScriptRoot\Lib"
#================================================================

#create dir structure
If ((Test-Path $lib_dir_name) -eq $False) { mkdir $lib_dir_name | Out-Null }

#import assemblies into session
Add-Type -Assembly "System.IO.Compression.FileSystem"

#download and extract iTextSharp library
If ((Test-Path $itextsharp_zip_name) -eq $False) { 
	Write-Output "Downloading: '$itextsharp_url'  To: '$itextsharp_zip_name'"
	Invoke-WebRequest -Uri $itextsharp_url -OutFile  $itextsharp_zip_name
}

If ((Test-Path $itextsharp_zip_name) -eq $True)
{
	$zip = [IO.Compression.ZipFile]::OpenRead($itextsharp_zip_name)
	
	#extract itextsharp libraries
	$zip.Entries | Where FullName -match "itextsharp.dll" | % {
		$dir = (Get-Item $lib_dir_name).FullName
		$file = $dir + "\" + $_.Name
		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $file, $true) 
	}

	$zip.Dispose()
	Remove-Item $itextsharp_zip_name -Force
}

#download and extract BouncyCastle library
If ((Test-Path $BouncyCastle_zip_name) -eq $False) { 
	Write-Output "Downloading: '$BouncyCastle_url'  To: '$BouncyCastle_zip_name'"
	Invoke-WebRequest -Uri $BouncyCastle_url -OutFile  $BouncyCastle_zip_name
}

If ((Test-Path $BouncyCastle_zip_name) -eq $True)
{
	$zip = [IO.Compression.ZipFile]::OpenRead($BouncyCastle_zip_name)
	
	#extract BouncyCastle libraries
	$zip.Entries | Where FullName -match "BouncyCastle.Crypto.dll" | % {
		$dir = (Get-Item $lib_dir_name).FullName
		$file = $dir + "\" + $_.Name
		[IO.Compression.ZipFileExtensions]::ExtractToFile($_, $file, $true) 
	}

	$zip.Dispose()
	Remove-Item $BouncyCastle_zip_name -Force
}