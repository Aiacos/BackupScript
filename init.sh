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
brew install wget
wget https://raw.githubusercontent.com/Aiacos/BackupScript/master/vscode.sh?token=AET6NHOW7MKC7XQTNBH6YA25QZ6YG -o vscode.sh
# search *.sh
config_file=$(find -L "${PWD}" -name \vscode.sh | sort)
echo "==> Found ${config_file}"


# Atom Packages
#if...e --install-extension ms-vscode.cpptools
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension PKief.material-icon-theme
code --install-extension saviof.mayacode
code --install-extension kiteco.kite

# Atom Packages
#if...
brew install wget
wget https://raw.githubusercontent.com/Aiacos/BackupScript/master/atom.sh?token=AET6NHJ77I52Q3NCA3KILLS5QZ664 -o atom.sh