Do {

# this collects the percent cpu usage
$ProcessName = "virtualboxvm"
$CpuCores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
$Samples = (Get-Counter "\Process($Processname*)\% Processor Time").CounterSamples
$Samples | Select @{Name="CookedValue";Expression={[Decimal]::Round(($_.CookedValue / $CpuCores), 2)}} 

# ths collects the private and virtual bytes
$privateBytes = (Get-Counter -Counter "\Process($Processname*)\Private Bytes").CounterSamples
$privateBytes | Select CookedValue

$virtualBytes = (Get-Counter -Counter "\Process($Processname*)\Virtual Bytes").CounterSamples
$virtualBytes | Select CookedValue

sleep 5

}

while ($true)