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
mas lucky TheUnarchiver
mas lucky MicrosoftRemoteDesktop

# Intsall Brew Cask
brew install btop
brew install neofetch
brew install cmatrix
brew install --cask opera
brew install --cask blender
brew install --cask discord
brew install --cask sensei
brew install --cask anydesk
brew install --cask megasync
brew install --cask qsync-client
brew install --cask amethyst
brew install --cask battle-net
brew install --cask speedify
brew install --cask affinity-photo


## Intsall Dev Environment
mas lucky Xcode
sudo xcodebuild -license accept

## Install Dev Editor and IDE
# Intsall Brew Cask Dev
brew install --cask pycharm-ce
brew install --cask gitkraken


## ZSH
# Prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

tee -a ~/.zshrc << EOF
# zplug configuration
source ~/.zplug/init.zsh

# Install and load plugins
zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/osx",   from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions"
zplug "clvv/fasd"
zplug "b4b4r07/enhancd"
zplug "junegunn/fzf"
zplug "Peltoche/lsd"
zplug "g-plane/zsh-yarn-autocompletions"
zplug "romkatv/powerlevel10k", as:theme, depth:1

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        zplug install
    fi
fi

# Load plugins
zplug load
EOF

# install plugins
source ~/.zshrc && zplug install

# install nerd font
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font

# Theme
# Set the prompt theme to load.
# Setting it to 'random' loads a random theme.
# Auto set to 'off' on dumb terminals.
echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> ~/.zpreztorc
p10k configure

# Dracula theme
cd
mkdir settings
cd settings
git clone https://github.com/dracula/terminal-app.git
