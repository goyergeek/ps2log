

($ParameterList.Values | Select-Object * | Where-Object{($_.ParameterSets.Keys -eq "ps2log")})


foreach($Param in $ParameterList | WHERE-Object {$_.ParameterSets.Keys -eq "ps2log"}){
    Write-Host $Param
}


$ParameterList = (Get-Command -Name New-Ps2LogConfig).Parameters
$ps2LogParams = ($ParameterList.Values | 
    Select-Object * | 
    Where-Object{($_.ParameterSets.Keys -eq "ps2log")}
)

foreach($arg in $ps2LogParams.Name) {
    Write-Host "This is $arg"
}