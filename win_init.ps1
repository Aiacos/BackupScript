## Install Scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex

scoop bucket add extras

## Install Software

# Internet
scoop install opera
scoop intsall discord

# Game
scoop install steam

# System
scoop intsall 7zip

# Programming
scoop install gitkraken
scoop install pycharm
scoop inatall atom

# Atom Extension
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
