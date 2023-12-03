param(
	[Parameter(Mandatory=$true)]
    [string]
    $ConfigFolderPath,
	
	[Parameter(Mandatory=$true)]
    [string]
    $BaseTabPath,
	
	[Parameter(Mandatory=$false)]
    [string]
    $WindowsTerminalProfileName = "PowerShell Core"
)

$ConfigFileName = "config.json"
$ConfigAdditionsFileName = "config-additions.json"
$PreScriptFileName = "PreScript.ps1"
$PreScriptAdditionsFileName = "PreScript-Additions.ps1"

$configFileFullPath = Join-Path $ConfigFolderPath $ConfigFileName

if (!(Test-Path $configFileFullPath)) {
	Write-Error "Could not find file: $configFileFullPath"
}
else {
	$config = Get-Content -Raw $configFileFullPath | ConvertFrom-Json
	
	if ($config.tabs.Length -lt 1) {
		Write-Warning "No tabs found in configuration"
	}
	else {

		###################################################################################
		###################################################################################
		# Load configs and build execution scripts
		###################################################################################

		$tabs = $config.tabs

		$configAdditionsFileFullPath = Join-Path $ConfigFolderPath $ConfigAdditionsFileName
		if (Test-Path $configAdditionsFileFullPath) {
			$configAdditions = Get-Content -Raw $configAdditionsFileFullPath | ConvertFrom-Json
			if ($configAdditions.tabs.length -gt 0)	{
				$tabs = $tabs + $configAdditions.tabs
			}
		}
		
		$configScriptFolder = Join-Path $BaseTabPath "TempTerminalTabsEnvironment"
		if (!(Test-Path $configScriptFolder)) {
			New-Item -ItemType Directory $configScriptFolder | Out-Null
		}
		
		$windowsTerminalParameters = ""
		
		$tabNumber = 0
		foreach ($tab in $tabs) {
			$tabNumber++
			$directory = $tab.directory
			if ($tab.isRelative) {
				$directory = Join-Path $BaseTabPath $directory
			}
			
			$scriptFileContents = "#script for tab $tabNumber
cd $directory
$($tab.command)
# end script
			"
			$scriptFileName = "script$($tabNumber).ps1"
			New-Item -Path $configScriptFolder -Name $scriptFileName -ItemType File -Value $scriptFileContents -Force | Out-Null
			$windowsTerminalParameters += " -p ""$WindowsTerminalProfileName"" -d ""$configScriptFolder"" --title ""$($tab.title)"" pwsh.exe -NoExit ""$($scriptFileName)""``;"
		}
		
		$startScriptContent = "#start script
wt$($windowsTerminalParameters) focus-tab -t $($config.focusTab)"
		$startScriptFileName = "start.ps1"
		New-Item -Path $configScriptFolder -Name $startScriptFileName -ItemType File -Value $startScriptContent -Force | Out-Null

		###################################################################################
		###################################################################################
		# Prompt if required
		###################################################################################

		if ($config.prompt) {
			Write-Host -NoNewLine 'Press any key to start...'
			$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
			Write-Host 
		}

		###################################################################################
		###################################################################################
		# Execute Pre Scripts if required
		###################################################################################

		$preScriptFileFullPath = Join-Path $ConfigFolderPath $PreScriptFileName
		if (Test-Path $preScriptFileFullPath) {
			& wt -p $WindowsTerminalProfileName -d $ConfigFolderPath --title "PreScript" pwsh.exe $preScriptFileFullPath;
		}

		$preScriptAdditionsFileFullPath = Join-Path $ConfigFolderPath $PreScriptAdditionsFileName
		if (Test-Path $preScriptAdditionsFileFullPath) {
			& wt -p $WindowsTerminalProfileName -d $ConfigFolderPath --title "PreScript Additions" pwsh.exe $preScriptAdditionsFileFullPath;
		}
		
		###################################################################################
		###################################################################################
		# Execute tabs startup
		###################################################################################

		$exec = Join-Path $configScriptFolder $startScriptFileName
		pwsh.exe $exec
	}
}
