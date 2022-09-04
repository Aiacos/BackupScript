# Update
sudo dnf update -y

# Install Tweak
pip3 install --user gnome-extensions-cli
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,close'

# Configure SSH
sudo dnf install openssh-server -y
sudo systemctl enable sshd
sudo systemctl start sshd

# Install Apps
sudo dnf install neofetch -y
sudo dnf install btop -y
