<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.127
	 Created on:   	9/15/2016 1:25 PM
	 Created by:   	Richard Smith, GSweet
	 Organization: 	
	 Filename:     	git-PortScan_TargetsSpecifiedInScript.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

# Import AD Module
Import-Module ActiveDirectory;
Write-Host "AD Module Imported";

# Enable PowerShell Remote Sessions
Enable-PSRemoting -Force;
Write-Host "PSRemoting Enabled";

# Set Execution Policy to Unrestricted
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "Execution Policy Set";

Function DetectTCPPorts{
	[cmdletbinding()]
	param ()
	
	$outputfile = "\\FILE_SERVER\Shares\UTILITY\log_rich-tcpPort.csv";
#	$outputfile = "\\FILE_SERVER\Shares\UTILITY\log_rich-tcpPort.txt";
	$timestamp = (Get-Date).ToString();
	$tcpConnStatus = ($Server+ "	-- Port in use: " + $TCPConn.Port);
	"$timestamp - $tcpConnStatus" | out-file $outputfile -Append;
	
	try{
		$TCPProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
		$TCPConns = $TCPProperties.GetActiveTcpListeners()
		foreach ($TCPConn in $TCPConns){
			if ($global:matchPorts -contains $TCPConn.Port){
				throw "$timestamp - $tcpConnStatus";
			}
		}
	}
	catch{
		$ErrorMessage = $_.Exception.InnerException.Message;
		Write-Error $_.Exception.Message;
	}
}

# Global array of ports to match on.
$global:matchPorts = "514", "8000", "8080", "8089", "9997";

# Sets the Server Inclusion List from a Text File
$ServerList = Get-Content "\\FILE_SERVER\Shares\UTILITY\list_TestPortHostTargets.txt"

ForEach ($Server in $ServerList){
	Write-Host "Starting";
	DetectTCPPorts
}
