Param(
    [Parameter(Mandatory=$true)]
    [String] $Path, #binary files location, the Path must contain directories with name: "primary\" & "secondary\"
    [Parameter(Mandatory=$true)]
    [String] $IDA,
    [Parameter(Mandatory=$true)]
    [String] $Out,
    $Arch="amd64"
)


function New-IDB($Bin)
{
    begin
    {
        if($Arch -eq "amd64")
        {
            $IDA = Join-Path $IDA "idat64.exe"
        }
        else
        {
            $IDA = Join-Path $IDA "idat.exe"
        }
    }
    process
    {
        foreach($b in $Bin)
        {
            $path = $b.FullName
            $arg = "-B $path"

            Wait-Process -Id (Start-Process $IDA -ArgumentList $arg -PassThru).Id
        }
    }
}



$primary = Get-ChildItem -Path (Join-Path $Path "primary")
$secondary = Get-ChildItem -Path (Join-Path $Path "secondary")

$primary_job = Start-Job -ScriptBlock {New-IDB -Bin $primary} -Name "Primary-IDB-generator"
$secondary_job = Start-Job -ScriptBlock {New-IDB -Bin $secondary} -Name "Secondary-IDB-generator"

$primary_job | Wait-Job
$secondary_job | Wait-Job