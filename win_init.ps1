## Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

## Install Software
# Driver
# choco install intel-dsa
choco install nvidia-display-driver --package-parameters="'/dch'"

# Internet
choco install opera
choco install discord.install
choco install qsync
choco install filezilla

# Graphics
choco install wacom-drivers
choco install maya

# System
choco install parsec --params "/Shared"
choco install anydesk.install
choco install 7zip.install

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
