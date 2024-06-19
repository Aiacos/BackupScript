## Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

## Install Software
# Driver
# choco install intel-dsa
choco install nvidia-display-driver

# Internet
choco install opera
choco install discord.install
choco install megasync
choco install qsync
choco install filezilla

# Graphics
choco install wacom-drivers
choco install blender
choco install maya
choco install quixelbridge

# System
choco install parsec --params "/Shared"
choco install 7zip.install
choco install screentogif.install

# Programming
choco install git.install
choco install gitkraken
choco install pycharm-community
choco install notepadplusplus

# Game
choco install battle.net
choco install steam

# Utils
# choco install ledger-live
# choco install openrgb
# choco install icue
# choco install logitechgaming

## Scoop installer
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex

# Btop4win-LHM
scoop install btop-lhm

# Terminal
choco install nerd-fonts-meslo
#choco install starship

# WSL
#wsl --install

## Windows Settings
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
