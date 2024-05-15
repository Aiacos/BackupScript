# Update
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

# Dev Tools
sudo apt install git wget curl ruby zsh lsd -y
sudo apt install build-essential -y
sudo apt install net-tools -y
sudo apt install python3 python3-pip pipx -y

# Configure SSH
sudo apt install openssh-server -y

# Install Apps
sudo apt install neofetch -y
sudo apt install btop -y
sudo apt install tmux -y
sudo apt install cmatrix -y
sudo apt install gnome-tweaks -y
sudo apt install gnome-shell-extension-manager -y
sudo apt install gedit -y
sudo apt install geany -y

# Snap

# Add Flatpack
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#sudo flatpak install flathub com.anydesk.Anydesk -y
sudo flatpak install flathub org.blender.Blender -y
sudo flatpak install flathub org.kde.krita -y
sudo flatpak install flathub com.axosoft.GitKraken -y
sudo flatpak install flathub com.jetbrains.PyCharm-Community -y
sudo flatpak install flathub org.gnome.Builder -y
sudo flatpak install flathub nz.mega.MEGAsync -y

# CasaOS
curl -fsSL https://get.casaos.io | sudo bash
sudo groupadd docker
sudo usermod -aG docker $USER

# Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/aiacos/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install jesseduffield/lazygit/lazygit
brew install jesseduffield/lazydocker/lazydocker

# Install Tweak
pipx install gnome-extensions-cli --system-site-packages
cd $HOME/.local/share/pipx/venvs/gnome-extensions-cli/bin

./gnome-extensions-cli install extensions@abteil.org
./gnome-extensions-cli install services-systemd@abteil.org
#./gnome-extensions-cli install arcmenu@arcmenu.com
#./gnome-extensions-cli install rocketbar@chepkun.github.com
#./gnome-extensions-cli install tiling-assistant@leleat-on-github
./gnome-extensions-cli install trayIconsReloaded@selfmade.pl
./gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
#./gnome-extensions-cli install tophat@fflewddur.github.io
./gnome-extensions-cli install blur-my-shell@aunetx

cd

#gsettings set org.gnome.desktop.interface color-scheme prefer-dark
#gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
#gsettings set org.gnome.desktop.interface icon-theme 'Numix-Square'
#gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'

# Dracula theme
sudo apt-get install dconf-cli -y
cd
mkdir .settings
cd .settings

# Dracula Gnome Terminal
git clone https://github.com/dracula/gnome-terminal
cd gnome-terminal
./install.sh

# Dracula Wallpaper
cd ..
git clone https://github.com/dracula/wallpaper.git

# PoP Shell
sudo apt install git node-typescript make -y
git clone https://github.com/pop-os/shell.git
cd shell
make local-install

cd 

# Configure ZSH
# Terminal Setup with Prezto
# Nerd Fonts
(curl -Lo "~/.fonts/MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf") &> /dev/null

# Install Prezto
zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Create Prezto Configuration
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  sudo ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Set zsh as default shell
sudo chsh -s /bin/zsh

# Add plugin anth theme


# Configure p10k
#p10k configure # Should start on new shell

# Grub
cd 
cd .settings
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -b -t tela
cd

## Tmux
## Environment setup
tee -a ~/.zshrc << EOF
# Startup tmux admin console
session="init"

# Check if the session exists, discarding output
# We can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]; then
  # Set up your session
  tmux new-session -s 'init' 'btop'\; split-window -h -p 40 \; split-window -v -p 50 \; select-pane -t 1 \; send-keys 'neofetch' C-m \; select-pane -t 2 \; send-keys 'clear' C-m \;
fi

# tmux attach-session -t $session
# tmux kill-session
EOF
