## Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install mas (AppStore from terminal)
brew install mas
mas signin uni.lorenzo.a@gmail.com "CaccaSecca86"

## Install Apps
# Install AppStore apps
mas lucky iStatMenus
mas lucky MeisterTask
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
brew cask install pycharm-ce
brew cask install gitkraken

# VSCode Packages
# if...
# wget file config
# delete file 
brew cask install visual-studio-code
code --install-extension akamud.vscode-theme-onedark
code --install-extension felipe.nasc-touchbar
code --install-extension FXTD-Odyssey.mayapy
code --install-extension JacquesLucke.blender-development
code --install-extension ms-python.python
code --install-extension ms-vscode.cpptools
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension PKief.material-icon-theme
code --install-extension saviof.mayacode
code --install-extension kiteco.kite

# Atom Packages
#if...