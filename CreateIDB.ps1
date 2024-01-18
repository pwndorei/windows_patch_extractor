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
	foreach($b in $Bin)
	{
		if($b.Extension -eq ".exe" -or $b.Extension -eq ".dll" -or $b.Extension -eq ".sys")
		{
			$path = $b.FullName
			$arg = "-B $path"

			Wait-Process -Id (Start-Process $IDA -ArgumentList $arg -PassThru -NoNewWindow).Id
		}
	}

}



$primary = Get-ChildItem -Path (Join-Path $Path "primary")
$secondary = Get-ChildItem -Path (Join-Path $Path "secondary")

New-IDB -Bin $primary
New-IDB -Bin $secondary