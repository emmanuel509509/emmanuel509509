# SPDX-FileCopyrightText: Copyright (c) 2023 ave9858 <edging.duj6i@simplelogin.com>
# SPDX-License-Identifier: CC0-1.0

$ErrorActionPreference = "Stop"
$regView = [Microsoft.Win32.RegistryView]::Registry32
$microsoft = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView).
OpenSubKey('SOFTWARE\Microsoft', $true)
$edgeUWP = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
$uninstallRegKey = $microsoft.OpenSubKey('Windows\CurrentVersion\Uninstall\Microsoft Edge')
if ($null -eq $uninstallRegKey) {
	Write-Error "Edge is not installed!"
}
$uninstallString = $uninstallRegKey.GetValue('UninstallString') + ' --force-uninstall'

$edgeClient = $microsoft.OpenSubKey('EdgeUpdate\ClientState\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}', $true)
if ($null -ne $edgeClient.GetValue('experiment_control_labels')) {
	$edgeClient.DeleteValue('experiment_control_labels')
}
$microsoft.CreateSubKey('EdgeUpdateDev').SetValue('AllowUninstall', '')
[void](New-Item $edgeUWP -ItemType Directory -ErrorVariable fail -ErrorAction SilentlyContinue)
[void](New-Item "$edgeUWP\MicrosoftEdge.exe" -ErrorAction Continue)
Start-Process cmd.exe "/c $uninstallString" -WindowStyle Hidden -Wait
[void](Remove-Item "$edgeUWP\MicrosoftEdge.exe" -ErrorAction Continue)

if (-not $fail) {
	[void](Remove-Item "$edgeUWP")
}

Write-Output "Edge should now be uninstalled!"
