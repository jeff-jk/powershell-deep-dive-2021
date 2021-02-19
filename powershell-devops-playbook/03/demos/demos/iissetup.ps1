## Enable IIS remote management

# Import ServerManager PowerShell module.
$null = Import-Module -Name ServerManager

# Verify the IIS Management Service Windows feature is enabled.
Write-Verbose "Verifying IIS Management Service Windows feature is enabled"
if ((Get-WindowsFeature -Name Web-Mgmt-Service).Installed) {
	# Enable Remote Management via a registry key.
	Write-Verbose "Enabling Remote Management via the registry"
	$null = Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1

	# Set the IIS Remote Management service to automatically start.
	Write-Verbose "Set IIS WMSvc service to automatically start"
	$null = Set-Service -Name WMSvc -StartupType Automatic

	# Start the IIS Remote Management service.
	Write-Verbose "Start IIS WMSvc"
	$null = Start-Service -Name WMSvc
} else {
	Add-WindowsFeature -Name Web-Mgmt-Service
}