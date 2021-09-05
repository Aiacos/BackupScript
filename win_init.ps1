<# Windows Install Script #>
﻿## Install Scoop
$env:SCOOP='C:\Scoop'
[environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')

$env:SCOOP_GLOBAL='c:\Apps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex

scoop bucket add extras

## Install Software

# Internet
scoop install -g opera
scoop intsall -g discord

# Game
scoop install -g steam

# System
scoop intsall -g 7zip
# iCue
#scoop bucket add TheRandomLabs https://github.com/TheRandomLabs/Scoop-Bucket.git
#scoop install -g corsair-icue

# Driver
#scoop install -g snappy-driver-installer-origin

# Programming
scoop install -g gitkraken
scoop install -g pycharm
scoop inatall -g atom

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
apm install maya
