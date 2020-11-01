<#
	PSDataReorg: Debug PDF Files (explode all rows of PDF file)
	----------------------------------------------------------------------------------------------------------------
	Author:				GSolone
	Version:			0.10
	Usage:				.\DataReorg_PDF_Debug.ps1 $pdffile
						(example) .\DataReorg_PDF_Debug.ps1 C:\temp\test.pdf
	Info:				https://gioxx.org/tag/psdatareorg
	Last update:		01-11-2020
	Updates:
		0.10- first public version, hello GitHub!
#>

<# PLEASE:
	- EXECUTE DataReorg_Setup.ps1 first! (only the first time, is necessary to create "Lib" folder and download iTextSharp and BouncyCastle).
#>

Param( [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)][string] $file )
Add-Type -Path "$PSScriptRoot\..\Lib\itextsharp.dll"
Add-Type -Path "$PSScriptRoot\..\Lib\BouncyCastle.Crypto.dll"

$logfileSource = $file -replace "\W"
$Today = Get-Date -format yyyyMMdd
$logFile = "Debug_$($logfileSource)_$($Today).log"

$pdfReader = New-Object iTextSharp.Text.Pdf.PdfReader -ArgumentList $file
$pageLines = [iTextSharp.Text.Pdf.Parser.PdfTextExtractor]::GetTextFromPage($pdfReader, 1).Split([Environment]::NewLine)
Write-Host $pageLines
$lineIndex = -1
foreach ($line in $pageLines) {
	$lineIndex++
	Out-File -FilePath "$($PSScriptRoot)\$($logFile)" -InputObject $line -Append
}
$pdfReader.Close()
Invoke-Item "$($PSScriptRoot)\$($logFile)"