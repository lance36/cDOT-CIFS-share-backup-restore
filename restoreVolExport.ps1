
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



$new_policies = Import-Clixml -Path $file


$new_policies | foreach { 

   $volume = $_.Name
   $policy = $_."Export Policy"



$q = get-ncvol -template
Initialize-NcObjectProperty $q VolumeIdAttributes
$q.VolumeIdAttributes.Name = $volume
$q.VolumeIdAttributes.OwningVserverName = $vserver
$a = Get-NcVol -Template
Initialize-NcObjectProperty $a VolumeExportAttributes
$a.VolumeExportAttributes.Policy= $policy
Update-NcVol -Query $q -Attributes $a

}