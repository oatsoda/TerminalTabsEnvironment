param(
	[Parameter(Mandatory=$true)]
    [string]
    $ConfigFilePath,
	
	[Parameter(Mandatory=$true)]
    [string]
    $BaseTabPath,
	
	[Parameter(Mandatory=$false)]
    [string]
    $WindowsTerminalProfileName = "PowerShell Core"
)

if (!(Test-Path $ConfigFilePath)) {
	Write-Error "Could not find file: $ConfigFilePath"
}
else {
	$config = Get-Content -Raw $ConfigFilePath | ConvertFrom-Json
	
	if ($config.tabs.Length -lt 1) {
		Write-Warning "No tabs found in configuration"
	}
	else {
		
		$configScriptFolder = Join-Path $BaseTabPath "TempTerminalTabsEnvironment"
		if (!(Test-Path $configScriptFolder)) {
			New-Item -ItemType Directory $configScriptFolder | Out-Null
		}
		
		$windowsTerminalParameters = ""
		
		$tabNumber = 0
		foreach ($tab in $config.tabs) {
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
		
		if ($config.prompt) {
			Write-Host -NoNewLine 'Press any key to start...'
			$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
			Write-Host 
		}
		
		$exec = Join-Path $configScriptFolder $startScriptFileName
		pwsh.exe $exec
	}
}
