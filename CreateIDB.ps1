Param(
    [Parameter(Mandatory=$true)]
    [String] $Path, #binary files location, the Path must contain directories with name: "primary\" & "secondary\"
    [Parameter(Mandatory=$true)]
    [String] $IDA,
    $Arch="amd64"
)


function New-IDB($Bin)
{

	if($Arch -eq "amd64")
	{
		$IDA = Join-Path $IDA "idat64.exe"
	}
	else
	{
		$IDA = Join-Path $IDA "idat.exe"
	}
	Write-Host $IDA
	Test-Path $IDA
	foreach($b in $Bin)
	{
		if($b.Extension -ne ".exe" -and $b.Extension -ne ".dll" -and $b.Extension -ne ".sys")
		{
			$b.Extension
			continue
		}
		$path = $b.FullName
		$arg = "-B $path"

		Wait-Process -Id (Start-Process $IDA -ArgumentList $arg -PassThru -NoNewWindow).Id
	}

}



$primary = Get-ChildItem -Path (Join-Path $Path "primary")
$secondary = Get-ChildItem -Path (Join-Path $Path "secondary")

$primary_job = Start-Job -ScriptBlock {New-IDB -Bin $input} -Name "Primary-IDB-generator" -InputObject $primary
$secondary_job = Start-Job -ScriptBlock {New-IDB -Bin $input} -Name "Secondary-IDB-generator" -InputObject $secondary

$primary_job | Wait-Job
$secondary_job | Wait-Job