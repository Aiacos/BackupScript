# Update
sudo dnf upgrade --refresh -y

# Install Tweak
pip3 install --user gnome-extensions-cli
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

gnome-extensions-cli install arcmenu@arcmenu.com
gnome-extensions-cli install rocketbar@chepkun.github.com
gnome-extensions-cli install tiling-assistant@leleat-on-github
gnome-extensions-cli install trayIconsReloaded@selfmade.pl
gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install tophat@fflewddur.github.io

sudo dnf install mint-y-icons -y
gsettings set org.gnome.desktop.interface icon-theme 'Mint-Y-Blue'

# Configure SSH
sudo dnf install openssh-server -y
sudo systemctl enable sshd
sudo systemctl start sshd

sudo dnf install xrdp -y
sudo systemctl enable --now xrdp

# Add Flatpack
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo -y

# Install Apps
sudo dnf install neofetch -y
sudo dnf install btop -y
sudo dnf install gedit -y
sudo dnf install geany -y

sudo flatpak install flathub com.anydesk.Anydesk -y
sudo flatpak install flathub org.blender.Blender -y
sudo flatpak install flathub org.kde.krita -y
sudo flatpak install flathub com.axosoft.GitKraken -y

## Environment setup
echo "# Startup tmux admin console" >> ~/.bashrc
echo "if tmux has-session ; then" >> ~/.bashrc
echo "	clear" >> ~/.bashrc
echo "else" >> ~/.bashrc
echo "  printf '\e[8;50;180t'; tmux new-session 'btop'\; split-window -h -p 50 \; split-window -v -p 50 \; select-pane -t 1 \; send-keys 'neofetch' C-m \; select-pane -t 2 \; send-keys 'clear' C-m \;" >> ~/.bashrc
echo "fi" >> ~/.bashrc