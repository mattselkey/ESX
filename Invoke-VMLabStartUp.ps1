<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String]
    $ESXHost="mskey-esx-mgmt.lab.local",
    [Parameter(Mandatory=$false)]
    [String]
    $User="administrator@vsphere.local",
    [Parameter(Mandatory=$false)]
    [String]
    $Pass
)

BEGIN{
try {
    #$cred = Get-Credential 
    Write-Information -Message "Connecting to host"
    set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    connect-viserver –server $ESXHost -User $User -Password $Pass 
    #connect-viserver –server $ESXHost -Credential $cred
}
catch {
    Write-Information -Message "error connecting to host, error is ($_)"  -InformationAction Continue
}
 
}

PROCESS{

 $VMs = Get-VM | Where-Object {Get-TagAssignment $_ | Where-Object{ $_.Tag -like "*POWERMANAGE*"}}
 
foreach ($VM in $VMs) {
  
    if($VM.powerstate -ne "PoweredOn"){
    Start-VM $VM
    }   
} 
}

END{
Disconnect-VIServer  -Confirm:$false
}