# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install mas (AppStore from terminal)
brew install mas
mas signin uni.lorenzo.a@gmail.com "CaccaSecca86"

# Install AppStore apps
mas lucky Xcode
sudo xcodebuild -license accept

mas lucky iStatMenus
mas lucky MeisterTask
mas lucky ForkLift
mas lucky AffinityPhoto
mas lucky MoneyPro
mas lucky TheUnarchiver

# Intsall Dev Envairomet
brew install python@2
brew install python

pip install PySide2

brew install kite

# Intsall Brew Cask
brew cask install blender
brew cask install discord
brew cask install pycharm
brew cask install gitkraken
brew cask install qsync-client

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
apm install atom-package-sync
apm install ide-python
apm install kite
