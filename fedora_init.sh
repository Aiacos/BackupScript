# Update
sudo dnf update -y

# Install Tweak
pip3 install --user gnome-extensions-cli
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,close'

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
