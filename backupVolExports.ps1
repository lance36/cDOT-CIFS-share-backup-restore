Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("f")] $file)

Import-Module "C:\Program Files (x86)\Netapp\Data ONTAP PowerShell Toolkit\DataONTAP"

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}


Get-NcVol -vserver  $vserver | Select Vserver,Name,@{N="Export Policy"; E={ $_.VolumeExportAttributes.Policy }} | Export-Clixml $file