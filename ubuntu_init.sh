# Update
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

sudo apt install net-tools -y

# Install Tweak
#sudo apt install gnome-tweaks -y
sudo apt install python3 python3-pip pipx -y
pipx install gnome-extensions-cli --system-site-packages
cd $HOME/.local/pipx/venvs/gnome-extensions-cli/bin

./gnome-extensions-cli install extensions@abteil.org
./gnome-extensions-cli install services-systemd@abteil.org
#./gnome-extensions-cli install arcmenu@arcmenu.com
#./gnome-extensions-cli install rocketbar@chepkun.github.com
./gnome-extensions-cli install tiling-assistant@leleat-on-github
./gnome-extensions-cli install trayIconsReloaded@selfmade.pl
./gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
#./gnome-extensions-cli install tophat@fflewddur.github.io
./gnome-extensions-cli install blur-my-shell@aunetx

cd

#gsettings set org.gnome.desktop.interface color-scheme prefer-dark
#gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
#gsettings set org.gnome.desktop.interface icon-theme 'Numix-Square'

# Configure ZSH
sudo apt install git wget curl ruby zsh -y
chsh -s $(which zsh)
curl -fsSL https://raw.githubusercontent.com/JGroxz/presto-prezto/main/presto-prezto.sh | bash -s -- --font
p10k configure

# Dracula theme
sudo apt-get install dconf-cli -y
cd
mkdir settings
cd settings
git clone https://github.com/dracula/gnome-terminal
cd gnome-terminal
./install.sh
cd ..
git clone https://github.com/dracula/wallpaper.git
cd 

# Configure SSH
sudo apt install openssh-server -y

# Install Apps
sudo apt install neofetch -y
sudo apt install btop -y
sudo apt install gedit -y
sudo apt install geany -y
sudo apt install cmatrix -y

# Add Flatpack
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#sudo flatpak install com.freerdp.FreeRDP
sudo flatpak install flathub com.anydesk.Anydesk -y
sudo flatpak install flathub org.blender.Blender -y
sudo flatpak install flathub org.kde.krita -y
sudo flatpak install flathub com.axosoft.GitKraken -y
sudo flatpak install flathub com.jetbrains.PyCharm-Community -y
sudo flatpak install flathub org.gnome.Builder -y
sudo flatpak install flathub nz.mega.MEGAsync -y


## Tmux
## Environment setup
sudo apt install tmux -y
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
