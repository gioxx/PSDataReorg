<#
	PSDataReorg: Moving PDF files from "root" to folders and subfolders (Year/Month) using date found in "line 11"
	----------------------------------------------------------------------------------------------------------------
	Author:				GSolone
	Version:			0.10
	Usage:				.\DataReorg_PDF_LineBased.ps1 $SourceFolder $DestFolder $Year
						(optional, recursive) .\DataReorg_PDF_LineBased.ps1 $SourceFolder $DestFolder $Year -Recursive
						(example) .\DataReorg_PDF_LineBased.ps1 C:\temp C:\temp 2020 -Recursive
	Info:				https://gioxx.org/tag/psdatareorg
	Last update:		01-11-2020
	Credits:			https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress?view=powershell-7
						https://stackoverflow.com/a/57724052/2220346
						https://www.nuget.org/packages/iTextSharp/
						https://ss64.com/ps/substring.html
						https://github.com/jourdant/powershell-paperless/
						https://github.com/berrnd/deutsche-bahn-online-ticket-parser
						https://stackoverflow.com/a/31784829/2220346
						https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-detecting-if-a-string-ends-with-a-certain/ba-p/307848
	Updates:
		0.10- first public version, hello GitHub!
#>

<# PLEASE:
	- EXECUTE DataReorg_Setup.ps1 first! (only the first time, is necessary to create "Lib" folder and download iTextSharp and BouncyCastle).
	- READ the Readme file to know how you can use this script.
#>

Param( 
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)][string] $Source, 
    [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)][string] $Destination,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)][string] $YearFilter,
	[switch] $Recursive
)

$dateLine = 10
$filesFilter = "*.pdf"
$filesCounter = 0

if (-not($Source.EndsWith('\'))) { $Source += '\' }
if (-not($Destination.EndsWith('\'))) { $Destination += '\' }
$Today = Get-Date -format yyyyMMdd
$TodayProgress = [string]::Format("{0:dd/MM/yyyy}", [datetime]::Now.Date)
$TimeIsProgress = (get-date).tostring('HH:mm:ss')
$logfileSource = $Source -replace "\W"
$logFile = "$($Destination)DataReorg_$($Today)_$($logfileSource).log"

Add-Type -Path "$PSScriptRoot\Lib\itextsharp.dll"
Add-Type -Path "$PSScriptRoot\Lib\BouncyCastle.Crypto.dll"

if ($Recursive) {
	$files = Get-ChildItem -Path $Source -Recurse -Filter $filesFilter | Sort-Object Name
	$TotalItems = $files.Count
} else {
	$files = Get-ChildItem -Path $Source -Filter $filesFilter | Sort-Object Name
	$TotalItems = $files.Count
}

ForEach ($file in $files) {
	$pdfReader = New-Object iTextSharp.Text.Pdf.PdfReader -ArgumentList $file.FullName
	$pageLines = [iTextSharp.Text.Pdf.Parser.PdfTextExtractor]::GetTextFromPage($pdfReader, 1).Split([Environment]::NewLine)
	$lineIndex = -1
	foreach ($line in $pageLines) {
		$lineIndex++
		if ($lineIndex -eq $dateLine) { $DateRow = $line.Trim() }
	}
	$pdfReader.Close()

	$CleanDate = $DateRow.Substring($DateRow.get_Length()-10)
	$CleanDate = $CleanDate -replace '/',''
	$year = $CleanDate.Substring(4,4)
	$month = $CleanDate.Substring(2,2)
	$day = $CleanDate.Substring(0,2)
			
	if ([string]::IsNullOrEmpty($YearFilter)) {
		$Directory = $Destination + $year + "\" + $month
	} else {
		if ($YearFilter -eq $year) { $Directory = $Destination + $month } else { $Directory = $Destination + $year + "\" + $month }
	}
	
	$filesCounter++
	if (!(Test-Path $Directory)) { New-Item $directory -type directory }
	$Percentage = [math]::Round($filesCounter/$TotalItems*100,2)
	Write-Progress -Activity "Be patient, grab a Snickers ..." -Status "Moving $($file) to $($Directory) ($($filesCounter)/$($TotalItems) - $Percentage%)" -PercentComplete ($filesCounter/$TotalItems*100)
	Add-Content -Path $logFile -Value "$TodayProgress $TimeIsProgress - $file with $DateRow moved to $Directory"
	$file | Move-Item -Destination $Directory
}