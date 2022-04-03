## Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Brew management
# brew doctor
# brew update
# brew upgrade
# brew cask upgrade
# brew cask upgrade --greedy

# brew update && brew upgrade && brew cask upgrade --greedy

# Install mas (AppStore from terminal)
brew install mas
mas signin uni.lorenzo.a@gmail.com "CaccaSecca86"

## Install Apps
# Install AppStore apps
mas lucky MeisterTask
mas lucky AffinityPhoto
mas lucky MoneyPro
mas lucky TheUnarchiver
mas lucky MicrosoftRemoteDesktop

# Intsall Brew Cask
#brew cask install google-chrome
brew cask install opera
brew cask install blender
brew cask install discord
brew install --cask sensei
brew cask install qsync-client
brew cask install battle-net
brew cask install speedify


## Intsall Dev Environment
mas lucky Xcode
sudo xcodebuild -license accept

# Install Python
brew install python
brew install python@2

/usr/local/bin/python3 -m pip install 'python-language-server[all]'
pip install PySide2

## Install Dev Editor and IDE
# Intsall Brew Cask Dev
brew cask install pycharm-ce
brew cask install gitkraken

# Atom
brew cask install atom

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
apm install atom-maya-quick-help
apm install maya

/usr/local/bin/python3 -m pip install 'python-language-server[all]'
