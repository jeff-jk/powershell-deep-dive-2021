<LOCALWINDOWSHOST>
    ==============
    
    #region Find our Window Server and Ansible host's public IP
    function Get-AzVmPublicIp {
        [CmdletBinding()]
        param(
            [parameter()]
            $VmName,
    
            [parameter()]
            $ResourceGroup
        )
    
        $vm = Get-AzVM -Name $VmName -ResourceGroupName $ResourceGroup
        $nicName = $vm.NetworkProfile[0].NetworkInterfaces.Id.Split('/')[-1]
    
        ## Find the public IP ID
        $nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $vm.ResourceGroupName
        $pubIpId = $nic.IpConfigurations.publicIpAddress.Id
    
        ## Find the public IP using the ID of the public IP address
        $pubIpObject = Get-AzPublicIpAddress -ResourceGroupName $vm.ResourceGroupName | Where-Object { $_.Id -eq $pubIpId }
        $pubIpObject.IpAddress
    }
    
    $winHostIp = Get-AzVmPublicIp -VmName WINSRV19 -ResourceGroup Course-PowerShellDevOpsPlaybook
    $controlNodeIp = Get-AzVmPublicIp -VmName ANSIBLECONTROL -ResourceGroup Course-PowerShellDevOpsPlaybook
    $winHostIp
    $controlNodeIp
    #endregion
    
    #region Define common variables we'll be working with
    
    ## Build a PS credential
    # https://blog.techsnips.io/how-to-create-a-pscredential-object-without-using-get-credential-in-powershell/
    $winHostAdminPassword = ConvertTo-SecureString -String 'I like azure.' -AsPlainText -Force ## Do as I say and not as I do here
    $winHostUserName = 'adam'
    $psCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $winHostUserName, $winHostAdminPassword
    #endregion
    
    #region Test PSRemoting session from local to remote Windows host and create a new session to use later
    ## Test PSRemoting to see if we can hit the Windows host from our local Windows host
    Test-WSMan -ComputerName $winHostIp -Credential $psCredential -Authentication Negotiate
    
    ## Create a PSRemoting session to re-use throughout the module
    $winHostSession = New-PSSession -ComputerName $winHostIp -Credential $psCredential
    #endregion
    
    #region Download and run the Ansible-provided WinRm script on the Windows host. Also allowing unencrypted HTTP traffic
    $scriptBlock = {
    	$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    	$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    	(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    	& $file
    	winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    }
    Invoke-Command -Session $winHostSession -ScriptBlock $scriptBlock
    #endregion

    <LOCALWINDOWSHOST>
    ==============
    
    ## We're going to need the Windows host IP in a minute. Let's copy it to the clipboard
    $winHostIp | Set-ClipBoard
    
    ## Connect to Ansible Control Node to update inventory to reflect connecting to Windows hosts using basic auth
    ssh adam@$controlNodeIp
    
    <ANSIBLEHOST>
    ==============
    > sudo vi /etc/ansible/hosts
    
    [windows]
    winsrv19 ansible_host=X.X.X.X
    
    [windows:vars]
    ansible_user=adam
    ansible_password=I like azure.
    ansible_connection=winrm
    ansible_winrm_transport=basic
    ansible_port=5985
    
    ## Test to ensure Ansible can communicate with the Windows host
    > ansible windows -m win_ping