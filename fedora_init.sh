# Update
sudo dnf update -y
sudo dnf -y --refresh upgrade

# Install Tweak
pip3 install --user gnome-extensions-cli
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,close'

# Install Apps