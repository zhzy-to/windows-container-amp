############################################################
# Script to enable Hyper-V and Containers features
############################################################

<#
    .SYNOPSIS
        Checks and installs Hyper-V and Containers features on Windows server

    .DESCRIPTION
        This script checks if Hyper-V and Containers features are enabled on the system.
        If not, it installs these features and restarts the system if necessary.

    .PARAMETER Force
        If a restart is required, forces an immediate restart.

    .PARAMETER NoRestart
        If a restart is required, the script will terminate and will not reboot the machine.

    .EXAMPLE
        .\Enable-HyperV-Containers.ps1

    .EXAMPLE
        .\Enable-HyperV-Containers.ps1 -Force

#>

[CmdletBinding()]
param(
    [switch] $Force,
    [switch] $NoRestart
)

$global:RebootRequired = $false

function Install-Feature {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$FeatureName
    )

    Write-Output "Checking status of Windows feature: $FeatureName..."
    if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
        $feature = Get-WindowsFeature $FeatureName
        if ($feature.Installed) {
            Write-Output "Feature $FeatureName is already enabled."
        } else {
            Test-Admin
            Write-Output "Enabling feature $FeatureName..."
            $featureInstall = Add-WindowsFeature $FeatureName
            if ($featureInstall.RestartNeeded -eq "Yes") {
                $global:RebootRequired = $true
            }
        }
    } else {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
        if ($feature.State -eq "Enabled") {
            Write-Output "Feature $FeatureName is already enabled."
        } else {
            Test-Admin
            Write-Output "Enabling feature $FeatureName..."
            $feature = Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
            if ($feature.RestartNeeded -eq $true) {
                $global:RebootRequired = $true
            }
        }
    }
}

function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $currentPrincipal.IsInRole($adminRole)) {
        throw "You must run this script as Administrator"
    }
}

function Restart-And-Run {
    Test-Admin
    Write-Output "Restart is required; restarting now..."

    $argList = $script:MyInvocation.Line.Replace($script:MyInvocation.InvocationName, "")
    $scriptPath = $script:MyInvocation.MyCommand.Path

    $argList = $argList -replace "\.\\", "$pwd\"
    if ((Split-Path -Parent -Path $scriptPath) -ne $pwd) {
        $sourceScriptPath = $scriptPath
        $scriptPath = "$pwd\$($script:MyInvocation.MyCommand.Name)"
        Copy-Item $sourceScriptPath $scriptPath
    }

    Write-Output "Creating scheduled task action ($scriptPath $argList)..."
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoExit $scriptPath $argList"
    Write-Output "Creating scheduled task trigger..."
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Write-Output "Registering script to re-run at next user logon..."
    Register-ScheduledTask -TaskName "EnableHyperVContainers" -Action $action -Trigger $trigger -RunLevel Highest | Out-Null

    try {
        if ($Force) {
            Restart-Computer -Force
        } else {
            Restart-Computer
        }
    } catch {
        Write-Error $_
        Write-Output "Please restart your computer manually to continue script execution."
    }
    exit
}

# Main script execution
try {
    Install-Feature -FeatureName "Containers"
    Install-Feature -FeatureName "Hyper-V"

    if ($global:RebootRequired) {
        if ($NoRestart) {
            Write-Warning "A reboot is required; stopping script execution"
            exit
        }
        Restart-And-Run
    } else {
        Write-Output "Hyper-V and Containers features are already enabled. No reboot required."
    }
} catch {
    Write-Error $_
}