Function Get-StoredCredential {
    <#
    .SYNOPSIS
        Returns a named credential object belonging to the current user/computer
        Naming allows multiple credentials to be stored for different purposes.
        If the saved credential is not found the user will br prompted and the credential stored
        Credentials are stored in the <userprofile>/secrets 
            
    .NOTES
        Name: Get-StoredCredential
        Author: /u/jimb2
        DateCreated: 2022-03-23 
        
    .EXAMPLE
        Get-StoredCredential -Name 'AD'            
        
        Loads/creates the stored credential 'AD'

    .EXAMPLE
        Get-StoredCredential -Name 'SQL'  -Renew   
        
        Recreates the stored credential 'SQL' eg on password change

    .EXAMPLE
        Get-StoredCredential 'AD' -NoCreate
        
        Returns null if there is no saved credential
        
    .EXAMPLE
        Get-StoredCredential 'AD' -Verbose
        
        Displays process steps and storage locations
    #>
        
    [CmdletBinding()]
    param(
        # Name : credential name or code, eg AD for AD updates 
        [Parameter( Mandatory = $true, Position = 0 )]
        [string]  $Name,
        # Renew switch: force updates the saved credential, eg, for password change
        [Parameter(Mandatory=$false)]
        [switch]  $Renew,
        # NoCreate switch: do not create if saved credential not found 
        [Parameter(Mandatory=$false)]
        [switch]  $NoCreate
        
        # Verbose switch, standard switch
    )

    BEGIN {
        Write-Verbose ".Get-StoredCredential - load/create a saved credential"
        Write-Verbose ".Name : $Name"
        Write-Verbose ".Flags: Renew=$Renew  NoCreate=$NoCreate" 
    }

    PROCESS {
        # Folder for credential, create if not found
        $CredFolder   = $env:USERPROFILE + '\Secrets'
        Write-Verbose ".Credfolder: $CredFolder" 

        if ( -not (Test-Path -Path $CredFolder) ) {
            Write-Verbose ".Credfolder not found, creating."
            New-Item -ItemType Directory -Force -Path $credFolder
        }
        # Credential filename
        $CredPath = "$CredFolder\Cred_$($Name)_${env:USERNAME}_${env:COMPUTERNAME}.xml"
        Write-Verbose ".CredPath: $Credpath" 

        $CredExists = Test-Path $CredPath
        Write-Verbose ".Credential found: $CredExists" 

        if ( $Renew -or ( !$CredExists -and !$NoCreate ) ) {
            # Prompt for credential
            Write-Verbose ".Creating credential"
            $cred = Get-Credential -Message "Enter Credential ($name)"
            $cred | Export-CliXml -Path $CredPath 
        } elseif ( $CredExists ) {
            # cred exist and not renewed
            Write-Verbose ".Loading credential"
            $cred = Import-CliXml -Path $CredPath
        } else {
            # cred does not exist and nocreate flag
            Write-Verbose ".Credential not found and NoCreate flag, return null!" 
            $cred = $null
        }
        #return the credential
        $cred
    }
}
