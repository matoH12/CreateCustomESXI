##############################################################################################
#     ____________  __ _    _                               __          _ __    __         
#    / ____/ ___/ |/ /(_)  (_)___ ___  ____ _____ ____     / /_  __  __(_) /___/ /__  _____
#   / __/  \__ \|   // /  / / __ `__ \/ __ `/ __ `/ _ \   / __ \/ / / / / / __  / _ \/ ___/
#  / /___ ___/ /   |/ /  / / / / / / / /_/ / /_/ /  __/  / /_/ / /_/ / / / /_/ /  __/ /    
# /_____//____/_/|_/_/  /_/_/ /_/ /_/\__,_/\__, /\___/  /_.___/\__,_/_/_/\__,_/\___/_/     
#                                         /____/                                           
##############################################################################################
# Author: Martin Hasin
# GitHub URL: https://github.com/matoH12
# Version: 2.0
# Example:
# .\createCustomEsxiInstallerImageV2.ps1 [path to esxi depot.zip] [path to folder with external package]
# .\createCustomEsxiInstallerImageV2.ps1 C:\Users\Administrator\Downloads\ESXi670-201912001.zip C:\Users\Administrator\Downloads\Cisco\
# 
##############################################################################
# Prerequisites
# Only needs to be executed once, not every time an image is built
# Must be Administrator to execute prerequisites
#
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
#Install-Module -Name VMware.PowerCLI -SkipPublisherCheck
##############################################################################
##############################################################################
# Argument
# you need write full path
$esxizipfile=$args[0]
# you need write full path
$pluginfolder=$args[1]
##############################################################################
##############################################################################
# Get the base ESXi image
##############################################################################
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false  -Confirm:$false
Add-EsxSoftwareDepot $esxizipfile

##############################################################################
# Add additional drivers  
##############################################################################
$files = (Get-ChildItem $pluginfolder -File -Filter *.zip).FullName
$i=0
while($i -lt $files.Length) { 
Add-EsxSoftwareDepot $files[$i];
$i++ 
}
##############################################################################
# Create new installation media profile and add the additional drivers to it
##############################################################################
#List all package you can install 
# Get-EsxSoftwarePackage | Sort-Object CreationDate | Format-Table -Property Name,Version,Vendor
$esxiversion = Get-EsxImageProfile | Select-Object Name 
$i=0


while($i -lt $esxiversion.Length) { 
$esxiversionlist += @([PSCustomObject]@{Number = $i;  Article = $esxiversion[$i]} );
$i++ 
}

Write-Output $esxiversionlist;

do {
$input = [int](Read-Host "Please enter the Array Value")

$inputint = [int]$input
$esxiselectedversion = $esxiversionlist | where {$_.Number -eq $inputint } | Select -ExpandProperty Article

}
#Loop will stop when user enter valid version
until ($input  -match $($esxiversionlist -join "|"))


Write-Output "You select" $esxiselectedversion.Name





Get-EsxSoftwarePackage | Sort-Object CreationDate | Select-Object Name,Version,Vendor



Clear-Variable -Name "esxiswlist"
$i=0


do {
$input = (Read-Host "Please enter the custom packege name to install. End proccess type END ")

if (( $input -ne 'END') -and ($input -ne '')) { 
    $esxiswlist += @([PSCustomObject]@{Number = $i;  Article = $input} );
    $i++
}

}
#Loop will stop when user enter valid version
until ($input -eq 'END')


Write-Output "You select" $esxiswlist



$esxicustomproffile = $esxiselectedversion.name + '-' + (Get-Date -Format "yyyy-MM-dd")
#remove existing profille
Remove-EsxImageProfile -ImageProfile $esxicustomproffile

# Create new, custom profile
New-EsxImageProfile -CloneProfile $esxiselectedversion.name -name  $esxicustomproffile  -Vendor "mhasin.eu" 


# ADD custom SW

$i=0
while($i -lt $esxiswlist.Length) { 

# Add ckage to custom profile
$esxiswlist2 = $esxiswlist | where {$_.Number -eq $i } | Select -ExpandProperty Article

Add-EsxSoftwarePackage -ImageProfile $esxicustomproffile -SoftwarePackage $esxiswlist2 

$i++ 
}


##############################################################################
# Export the custom profile to ISO
##############################################################################
$exportesxi = $esxicustomproffile + '.iso'

Export-ESXImageProfile -ImageProfile $esxicustomproffile -ExportToIso -filepath $exportesxi -force
