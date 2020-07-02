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
    This script requires PowerShell 7
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

    try{
        Get-InstalledModule -Name "Vmware.PowerCli" -ErrorAction Stop
        }
        catch{
            Write-Information -Message "Error install vmware modules"
            Install-Module -Name VMware.PowerCLI –Scope CurrentUser -Force
        
        }
pause

    try {

    $InformationPreference = "Continue"
    #$cred = Get-Credential 
    Write-Information -Message "Connecting to host"
    Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
    set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false | Out-Null
    connect-viserver -server $ESXHost -User $User -Password $Pass | Out-Null
    #connect-viserver –server $ESXHost -Credential $cred
}
catch {
    Write-Information -Message "error connecting to host, error is ($_)"
}
 
}

PROCESS{
 Write-Information -Message "Getting Power Managed VMs"
 try{
    $VMs = Get-VM | Where-Object {Get-TagAssignment $_ | Where-Object{ $_.Tag -like "*POWERMANAGE*"}}
 }catch{
    Write-Information -Message "Error getting VM tags. Error is ($_)"
 }

foreach ($VM in $VMs) {
  
    if($VM.powerstate -ne "PoweredOn"){
    
     Write-Information -Message "Starting VM $($VM)"

    Start-VM $VM | Out-Null
    }   
} 

}

END{
Disconnect-VIServer  -Confirm:$false
}