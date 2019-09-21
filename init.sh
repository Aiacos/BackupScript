## Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install mas (AppStore from terminal)
brew install mas
mas signin uni.lorenzo.a@gmail.com "CaccaSecca86"

## Install Apps
# Install AppStore apps
mas lucky iStatMenus
mas lucky MeisterTask
mas lucky ForkLift
mas lucky AffinityPhoto
mas lucky MoneyPro
mas lucky TheUnarchiver

# Intsall Brew Cask
brew cask install google-chrome
brew cask install blender
brew cask install discord
brew cask install qsync-client

## Intsall Dev Environment
mas lucky Xcode
sudo xcodebuild -license accept

# Install Python
brew install python@2
brew install python

pip install PySide2

## Install Dev Editor and IDE
brew install kite

# Intsall Brew Cask Dev
brew cask install pycharm
brew cask install gitkraken
brew cask install atom

# Atom Packages
apm install teletype
apm install file-icons
apm install atom-file-icons
apm install script
apm install tool-bar
apm install tool-bar-atom

apm install python-tools
apm install atom-beautify
apm install tool-bar
apm install tool-bar-atom
apm install atom-ide-debugger-python
apm install atom-ide-ui
apm install ide-python
apm install kite
apm install atom-package-sync
