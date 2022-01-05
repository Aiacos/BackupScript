## Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
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
choco install wacom-drivers
# choco install maya

# Utils
# choco install ledger-live

# System
choco install parsec --params "/Shared"
choco install 7zip.install
# choco install icue
# choco install logitechgaming

# Driver
# choco install intel-dsa
# choco install nvidia-display-driver --package-parameters="'/dch'"

# Programming
choco install git.install
choco install gitkraken
choco install pycharm-community
choco install vscode.install --params "/NoDesktopIcon"
# choco install atom.install

# VSCode Extension
cmd.exe /c "code --install-extension ms-vsliveshare.vsliveshare"
cmd.exe /c "code --install-extension PKief.material-icon-theme"
cmd.exe /c "code --install-extension akamud.vscode-theme-onedark"
#cmd.exe /c "code --install-extension felipe.nasc-touchbar"

cmd.exe /c "code --install-extension ms-python.python"
cmd.exe /c "code --install-extension saviof.mayacode"
cmd.exe /c "code --install-extension FXTD-Odyssey.mayapy"
cmd.exe /c "code --install-extension JacquesLucke.blender-development"

# Atom Extension
# cmd.exe /c "apm install language-powershell"
# cmd.exe /c "apm install teletype"
# cmd.exe /c "apm install file-icons"
# cmd.exe /c "apm install atom-file-icons"
# cmd.exe /c "apm install script"
# cmd.exe /c "apm install tool-bar"
# cmd.exe /c "apm install tool-bar-atom"
# cmd.exe /c "apm install python-tools"
# cmd.exe /c "apm install atom-beautify"
# cmd.exe /c "apm install atom-ide-debugger-python"
# cmd.exe /c "apm install atom-ide-ui"
# cmd.exe /c "apm install ide-python"
# cmd.exe /c "apm install atom-maya-quick-help"
