# Usage:
# Run as: .\createSharesAcls.ps1 -server <mgmt_ip> -user <mgmt_user> -password <mgmt_user_password> -vserver <vserver name> -shareFile <xml file to get shares from > -aclFile <xml file to get acls from> -spit <none,less,more depending on info to print>
#
# Example
# 1. If you want to save create back shares form xml file C:\share.xml and acls from xml file C:\acls.xml on vserver vs2, with less information displayed on the screen 
# Run as:  .\createSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -shareFile C:\share.xml -aclFile C:\acl.xml -spit less 
#
# 2. If you only want to print the commands and not actually create the shares, use -printOnly 
# Run as:  .\createSharesAcls.ps1 -server 10.53.33.59 -user admin -password netapp1! -vserver vs2 -shareFile C:\share.xml -aclFile C:\acl.xml -spit less -printOnly true

Param([parameter(Mandatory = $true)] [alias("s")] $server,
      [parameter(Mandatory = $true)] [alias("u")] $user,
      [parameter(Mandatory = $true)] [alias("p")] $password,
      [parameter(Mandatory = $true)] [alias("v")] $vserver,
      [parameter(Mandatory = $true)] [alias("sf")] $shareFile,
      [parameter(Mandatory = $true)] [alias("af")] $aclFile,
      [parameter(Mandatory = $true)] [alias("sp")] [Validateset("none","less","more")]$spit,
      [alias("po")] [Validateset("false","true")] $printOnly = "false")
            
Import-Module C:\Windows\system32\WindowsPowerShell\v1.0\Modules\DataONTAP

$passwd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user, $passwd
$nctlr = Connect-NcController $server -Credential $cred
$nodesinfo = @{}

$new_shares = Import-Clixml -Path $shareFile

if ($spit -ne "none")
{
    echo "====================================================================================="
    echo "SHARES"
    echo "====================================================================================="

    if ($spit -eq "less")
    {
        $new_shares
    } 
    elseif ($spit -eq "more")
    {
        $new_shares | Format-List
    }
}
echo "====================================================================================="

$new_shares | foreach { 
   $mycmd = "Add-NcCifsShare -VserverContext $vserver"

   $myName = $_.ShareName

    if (($myName -eq "admin$") -or ($myName -eq "c$") -or ($myName -eq "ipc$"))
    {
        $mycmd = "Skip adding: " + $myName
        if ($spit -ne "none")
        {
            $mycmd
            echo "--------------------"
        }
        return
    }     
    
    if (($myName -ne $null) -and ($myName -ne ""))
    {
        $mycmd = $mycmd + " -Name ""$myName"""          
    }

    $myPath = $_.Path
    if (($myPath -ne $null) -and ($myPath -ne ""))
    {
        $mycmd = $mycmd + " -Path ""$myPath"""
    }

    $myComment = $_.Comment
    if (($myComment -ne $null) -and ($myComment -ne ""))
    {
        $mycmd = $mycmd + " -Comment ""$myComment"""          
    }

    $myShareProperties = $_.ShareProperties
    if (($myShareProperties -ne $null) -and ($myShareProperties -ne ""))
    {
        $myShareProp = ""
        foreach ($prop in $myShareProperties) {
            if ($myShareProp -eq "")
            {
                $myShareProp = $prop
            } 
            else
            {
                $myShareProp = $myShareProp , $prop -join ','
            }
        }
        $mycmd = $mycmd + " -ShareProperties ""$myShareProp"""          
    }

    $mySymlinkProperties = $_.SymlinkProperties
    if (($mySymlinkProperties -ne $null) -and ($mySymlinkProperties -ne ""))
    {
        $mySymlinkProp = ""
        foreach ($prop in $mySymlinkProperties) {
            if ($mySymlinkProp -eq "")
            {
                $mySymlinkProp = $prop
            } 
            else
            {
                $mySymlinkProp = $mySymlinkProp , $prop -join ','
            }
        }    
        $mycmd = $mycmd + " -SymlinkProperties ""$mySymlinkProp"""          
    } 

    $myFileUmask = $_.FileUmask
    if (($myFileUmask -ne $null) -and ($myFileUmask -ne ""))
    {
        $mycmd = $mycmd + " -FileUmask ""$myFileUmask"""          
    }

    $myDirUmask = $_.DirUmask
    if (($myDirUmask -ne $null) -and ($myDirUmask -ne ""))
    {
        $mycmd = $mycmd + " -DirUmask ""$myDirUmask"""          
    }

    $myOfflineFilesMode = $_.OfflineFilesMode
    if (($myOfflineFilesMode -ne $null) -and ($myOfflineFilesMode -ne ""))
    {
        $mycmd = $mycmd + " -OfflineFilesMode ""$myOfflineFilesMode"""          
    }

    $myAttributeCacheTtl = $_.AttributeCacheTtl
    if (($myAttributeCacheTtl -ne $null) -and ($myAttributeCacheTtl -ne ""))
    {
        $mycmd = $mycmd + " -AttributeCacheTtl ""$myAttributeCacheTtl"""          
    }

    $myVscanProfile = $_.VscanProfile
    if (($myVscanProfile -ne $null) -and ($myVscanProfile -ne ""))
    {
        $mycmd = $mycmd + " -VscanProfile ""$myVscanProfile"""          
    }  

    if ($spit -ne "none")
    {
        $mycmd
        echo "--------------------"
    }

    if ($printOnly -eq "false")
    {
        Invoke-Expression $mycmd
        Remove-NcCifsShareAcl -VserverContext $vserver -Share $myName -UserOrGroup Everyone 
    }
}

$new_acls = Import-Clixml -Path $aclFile


if ($spit -ne "none")
{
    echo "====================================================================================="
    echo "ACLS"
    echo "====================================================================================="

    if ($spit -eq "less")
    {
        $new_acls
    } 
    elseif ($spit -eq "more")
    {
        $new_acls | Format-List
    }
    echo "====================================================================================="
}



$new_acls | foreach { 
    $mycmd = "Add-NcCifsShareAcl -VserverContext $vserver"
    
    $myShare = $_.Share

    if (($myShare -eq "admin$") -or ($myShare -eq "ipc$") -or ($myShare -eq "c$"))
    {
        $myCmd = "Skip adding Acls for " + $myShare
        if ($spit -ne "none")
        {
            $mycmd
            echo "--------------------"
        }
        return
    }
   
    if (($myShare -ne $null) -and ($myShare -ne ""))
    {
        $mycmd = $mycmd + " -Share ""$myShare"""          
    }
    
    $myUserGroupType = $_.UserGroupType
    if (($myUserGroupType -ne $null) -and ($myUserGroupType -ne ""))
    {
        $mycmd = $mycmd + " -UserGroupType ""$myUserGroupType"""
    }

    $myUserOrGroup = $_.UserOrGroup
    if (($myUserOrGroup -ne $null) -and ($myUserOrGroup -ne ""))
    {
        $mycmd = $mycmd + " -UserOrGroup ""$myUserOrGroup"""
    }

    $myPermission = $_.Permission
    if (($myPermission -ne $null) -and ($myPermission -ne ""))
    {
        $mycmd = $mycmd + " -Permission ""$myPermission"""          
    }
        
    if ($spit -ne "none")
    {
        $mycmd
        echo "--------------------"
    }

    if ($printOnly -eq "false")
    {
        Invoke-Expression $mycmd
    }    
}