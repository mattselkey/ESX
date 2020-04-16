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
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String]
    $vCenterHost="mskey-esx-mgmt.lab.local",
    [Parameter(Mandatory=$false)]
    [String]
    $User="administrator@vsphere.local",
    [Parameter(Mandatory=$false)]
    [String]
    $Pass,
    [Parameter(Mandatory=$false)]
    [String]
    $ESXHost="192.168.2.98"
)
BEGIN{
    try {
        $InformationPreference = "Continue"
        #$cred = Get-Credential 
        Write-Information -Message "Connecting to host"
        set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false  | Out-Null
        connect-viserver –server $vCenterHost -User $User -Password $Pass  | Out-Null
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
       
        }
       
       foreach ($VM in $VMs) {
         
        if($VM.powerstate -eq "PoweredOn"){
           
            
            if (Get-TagAssignment $VM | Where-Object {$_.Tag -like "*SUSPEND*"}) {
                Write-Information -Message "Suspending VM ($VM)"
                Suspend-VM $VM -Confirm:$false  | Out-Null
            }
            else{
                Write-Information -Message "Shutting down VM ($VM)"
                Stop-VMGuest  $VM -Confirm:$false  | Out-Null

            }
         }   
       }
       
       
       Disconnect-VIServer -Server $vCenterHost -Confirm:$false
       
       connect-viserver –server $ESXHost
       
       $VSCAName = Get-VM  | Where-Object {$_.Name -like "*VSCA*"}
       if($VM.powerstate -eq "PoweredOn"){
       Stop-VMGuest $VSCAName -Confirm:$false
       }
     
       Stop-VMHost -Server $ESXHost -Force -Confirm:$false

    }
       
    END{
       
    }

