############### Lista de máquinas via DHCP ###############

Clear-Content "D:\ScriptsAD\shutdown_pcs.txt"

$dhcplist = Get-DhcpServerv4Lease -ComputerName "ad.dominio.local" -ScopeId 192.168.0.0 |Select-Object -property HostName

"Flushing DNS"
#ipconfig /flushdns | out-null

"Registering DNS"
#ipconfig /registerdns | out-null

echo $dhcplist

$dhcplist = $dhcplist -replace '@{HostName=',''
$dhcplist = $dhcplist -replace '}',''
$dhcplist = $dhcplist -replace '\s',''

$shutdownlist = New-object System.Collections.ArrayList

Foreach($dhcphost in $dhcplist) {

  if (!(Test-Connection -Cn $dhcphost -BufferSize 16 -Count 1 -ea 0 -quiet))
  {
    $ping = 1
    "Cliente $dhcphost inacessível"
  }

  Else 
  
  {$ping = 0}

  if ($ping -eq 0)
  {
    $shutdownlist.Add($dhcphost)
    "Incluindo cliente $dhcphost na lista de estacoes ativas"
  }
   
}

$shutdownlist | Out-File "D:\ScriptsAD\shutdown_pcs.txt"


############### Shutdown de estações ###############

foreach ($_ in get-content "D:\ScriptsAD\shutdown_pcs.txt") {(gwmi Win32_OperatingSystem -ComputerName $_).Win32Shutdown(8)}


# Lista de códigos para o uso do Win32Shutdown( )
# 0 - logoff
# 4 - logoff forçado
# 1 - desligamento
# 5 - desligamento forçado
# 2 - reiniciar
# 6 - reinicialização forçada
# 8 - desligar
# 12 - desligamento forçado
