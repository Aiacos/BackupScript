# Update
sudo echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
sudo echo "fastestmirror=True" >> /etc/dnf/dnf.conf

#sudo dnf upgrade --refresh -y
sudo dnf update -y
sudo dnf upgrade -y

# Dev Tools
sudo dnf groupinstall "C Development Tools and Libraries" "Development Tools" -y
sudo dnf install mpfr-devel gmp-devel libmpc-devel zlib-devel glibc-devel.i686 glibc-devel isl-devel g++ gcc-gnat gcc-gdc libgphobos-static -y
sudo dnf install gcc gcc-c++ g++ cmake mesa-libGL-devel -y
sudo dnf install btrfs-assistant -y

# Configure SSH
sudo dnf install openssh-server -y
sudo systemctl enable sshd
sudo systemctl start sshd

sudo dnf install xrdp -y
sudo systemctl enable --now xrdp

# NVIDIA Driver
sudo dnf install akmod-nvidia -y
sudo dnf install xorg-x11-drv-nvidia-cuda -y
sudo dnf install cuda-toolkit -y

#sudo dnf install dnf-plugins-core -y
#sudo dnf copr enable t0xic0der/nvidia-auto-installer-for-fedora -y
#sudo dnf install nvautoinstall -y

#sudo nvautoinstall driver
#sudo nvautoinstall plcuda
#sudo nvautoinstall ffmpeg
#sudo nvautoinstall vulkan
#sudo nvautoinstall vidacc

# PoP Shell
sudo dnf install gnome-shell-extension-pop-shell -y

## Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/aiacos/.zshrc
echo 'export XDG_DATA_DIRS="/home/linuxbrew/.linuxbrew/share:$XDG_DATA_DIRS"' >> ~/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install zellij
brew install jesseduffield/lazygit/lazygit
brew install jesseduffield/lazydocker/lazydocker
brew install zsh-history-substring-search
brew install atuin
brew install dust
brew install jstkdng/programs/ueberzugpp

## Neovim setup
sudo dnf install neovim -y

# Dependencies
sudo dnf install npm nodejs cargo ripgrep fd-find clang clangd fzf -y  
sudo dnf install pipx python3-full python3-pynvim python3-ply -y  
cargo install tree-sitter-cli
brew install bottom

# Nerd Fonts
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash  

# Go disk usage
curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
sudo chmod +x gdu_linux_amd64
sudo mv gdu_linux_amd64 /usr/bin/gdu

# LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim --headless +q

# Install Apps
sudo dnf install neofetch -y
sudo dnf install btop -y
sudo dnf install gedit -y
sudo dnf install geany -y
sudo dnf install cmatrix -y
sudo dnf install sxiv -y
sudo dnf install chafa -y
sudo dnf install ranger -y
sudo dnf install ncdu -y

touch ~/.config/ranger/rc.conf
echo "set preview_images true" >> ~/.config/ranger/rc.conf
echo "set preview_images_method ueberzug" >> ~/.config/ranger/rc.conf

# Configure ZSH
sudo dnf install git wget curl ruby ruby-devel zsh util-linux-user redhat-rpm-config gcc gcc-c++ make -y
sudo dnf install powerline vim-powerline tmux-powerline powerline-fonts lsd -y
sudo dnf install fontawesome-fonts -y
chsh -s $(which zsh)

curl -fsSL https://raw.githubusercontent.com/Aiacos/presto-prezto/main/presto-prezto.sh | bash -s -- --font

# Dracula theme
sudo dnf install dconf-cli -y
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
cd 

# Zellij Base layout
tee -a ~/.zellij_base_layout.kdl << EOF
layout {
        default_tab_template {
                pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
                plugin location="zellij:status-bar"
        }
    }   
        tab name="Work" split_direction="Vertical" {
        pane split_direction="Vertical" {
            pane name="Btop" command="btop" {

            }
            pane split_direction="Horizontal" {
                pane name="System" command="neofetch" {

                }
                pane focus=true name="Shell" {

                }
            }
        }
    }
}
session_name "Base"
attach_to_session true

EOF

# Install Tweak
sudo dnf install gnome-tweaks -y
sudo dnf install python3 python3-pip -y
pip3 install --user gnome-extensions-cli

#gnome-extensions-cli install arcmenu@arcmenu.com
gnome-extensions-cli install rocketbar@chepkun.github.com
#gnome-extensions-cli install tiling-assistant@leleat-on-github
gnome-extensions-cli install trayIconsReloaded@selfmade.pl
gnome-extensions-cli install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install tophat@fflewddur.github.io
gnome-extensions-cli install blur-my-shell@aunetx

cd

sudo dnf install mint-y-icons -y
sudo dnf install numix-icon-theme -y
sudo dnf install numix-icon-theme-square -y
sudo dnf install numix-icon-theme-circle -y
sudo dnf install yaru-theme -y
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'


# Install Hyprland
git clone --depth=1 https://github.com/JaKooLit/Fedora-Hyprland.git ~/Fedora-Hyprland
cd ~/Fedora-Hyprland
chmod +x install.sh
./install.sh

# Deepin Desktop
#sudo dnf group install "Deepin Desktop" -y

## Grub
cd 
cd .settings
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -b -t tela
cd

# Add Flatpack
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install flathub com.anydesk.Anydesk -y
sudo flatpak install flathub org.blender.Blender -y
sudo flatpak install flathub org.kde.krita -y
sudo flatpak install flathub com.axosoft.GitKraken -y
sudo flatpak install flathub com.jetbrains.PyCharm-Community -y
