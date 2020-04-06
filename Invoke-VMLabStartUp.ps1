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
    [Parameter()]
    [String]
    $ESXHost
)
try {
    Write-Information -Message "Connecting to host"
    set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    connect-viserver –server $ESXHost  
}
catch {
    Write-Information -Message "error connecting to host, error is ($_)"  -InformationAction Continue
}

get-vm  

Disconnect-VIServer  -Confirm:$false