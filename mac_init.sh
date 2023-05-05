## Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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
mas lucky TheUnarchiver
mas lucky MicrosoftRemoteDesktop

# Intsall Brew Cask
brew install btop
brew install neofetch
brew install --cask opera
brew install --cask blender
brew install --cask discord
brew install --cask sensei
brew install --cask anydesk
brew install --cask qsync-client
brew install --cask amethyst
brew install --cask battle-net
brew install --cask speedify


## Intsall Dev Environment
mas lucky Xcode
sudo xcodebuild -license accept

## Install Dev Editor and IDE
# Intsall Brew Cask Dev
brew install --cask pycharm-ce
brew install --cask gitkraken
