# Update
sudo echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
sudo echo "fastestmirror=True" >> /etc/dnf/dnf.conf

#sudo dnf upgrade --refresh -y
sudo dnf update -y
sudo dnf upgrade -y

# Dev Tools
sudo dnf group install "C Development Tools and Libraries" "Development Tools" -y
sudo dnf install gcc gcc-c++ g++ cmake mesa-libGL-devel -y

# Install Tweak
#sudo dnf install gnome-tweaks -y
sudo dnf install python3 python3-pip -y
pip3 install --user gnome-extensions-cli
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

gnome-extensions-cli install arcmenu@arcmenu.com
gnome-extensions-cli install rocketbar@chepkun.github.com
gnome-extensions-cli install tiling-assistant@leleat-on-github
gnome-extensions-cli install trayIconsReloaded@selfmade.pl
gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install tophat@fflewddur.github.io

sudo dnf install mint-y-icons -y
sudo dnf install numix-icon-theme -y
sudo dnf install numix-icon-theme-square -y
sudo dnf install numix-icon-theme-circle -y
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Square'
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Deepin Desktop
#sudo dnf group install "Deepin Desktop" -y

# Configure ZSH
sudo dnf install git wget curl ruby ruby-devel zsh util-linux-user redhat-rpm-config gcc gcc-c++ make -y
git clone --depth=1 https://github.com/ryanoasis/nerd-fonts ~/.nerd-fonts
cd .nerd-fonts
sudo ./install.sh

chsh -s /usr/bin/zsh

sudo dnf install fontawesome-fonts -y
sudo dnf install powerline vim-powerline tmux-powerline powerline-fonts -y

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

# Configure SSH
sudo dnf install openssh-server -y
sudo systemctl enable sshd
sudo systemctl start sshd

sudo dnf install xrdp -y
sudo systemctl enable --now xrdp

# NVIDIA Driver
sudo dnf install akmod-nvidia -y
sudo dnf install xorg-x11-drv-nvidia-cuda -y

# Install Apps
sudo dnf install neofetch -y
sudo dnf install btop -y
sudo dnf install gedit -y
sudo dnf install geany -y
sudo dnf install cmatrix -y

# Add Flatpack
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install flathub com.anydesk.Anydesk -y
sudo flatpak install flathub org.blender.Blender -y
sudo flatpak install flathub org.kde.krita -y
sudo flatpak install flathub com.axosoft.GitKraken -y
sudo flatpak install flathub com.jetbrains.PyCharm-Community -y
