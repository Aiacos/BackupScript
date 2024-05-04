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

#gnome-extensions-cli install arcmenu@arcmenu.com
gnome-extensions-cli install rocketbar@chepkun.github.com
gnome-extensions-cli install tiling-assistant@leleat-on-github
gnome-extensions-cli install trayIconsReloaded@selfmade.pl
gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install tophat@fflewddur.github.io

# PoP Shell
sudo dnf install gnome-shell-extension-pop-shell -y

sudo dnf install mint-y-icons -y
sudo dnf install numix-icon-theme -y
sudo dnf install numix-icon-theme-square -y
sudo dnf install numix-icon-theme-circle -y
sudo dnf install yaru-theme -y
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'
#gsettings set org.gnome.desktop.interface icon-theme 'Numix-Square'
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
