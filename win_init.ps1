## Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

## Install Software
# Internet
choco install opera
choco install discord.install
choco install qsync

# Game
choco install battle.net
choco install steam

# Graphics
choco install maya

# System
choco install parsec --params "/Shared"
choco install 7zip.install
#choco install icue

# Driver
#choco install intel-dsa
#choco install nvidia-display-driver --package-parameters="'/dch'"

# Programming
choco install gitkraken
choco install pycharm-community
choco install atom.install

# Atom Extension
apm install language-powershell
apm install teletype
apm install file-icons
apm install atom-file-icons
apm install script
apm install tool-bar
apm install tool-bar-atom
apm install python-tools
apm install atom-beautify
apm install atom-ide-debugger-python
apm install atom-ide-ui
apm install ide-python
apm install atom-maya-quick-help
