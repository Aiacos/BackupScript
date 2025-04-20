## Update
#sudo echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
#sudo echo "fastestmirror=True" >> /etc/dnf/dnf.conf

sudo dnf update -y
sudo dnf upgrade -y

## System
sudo dnf install git curl wget pipx python3 python3-pip python3-full python3-pynvim python3-ply -y
sudo dnf install btrfs-assistant -y

# Dev Tools
sudo dnf groupinstall "C Development Tools and Libraries" "Development Tools" -y
sudo dnf install mpfr-devel gmp-devel libmpc-devel zlib-devel glibc-devel.i686 glibc-devel isl-devel g++ gcc-gnat gcc-gdc libgphobos-static gcc gcc-c++ cmake mesa-libGL-devel clang clangd -y

# Configure SSH
sudo dnf install openssh-server -y
sudo systemctl enable sshd
sudo systemctl start sshd

#sudo dnf install xrdp -y
#sudo systemctl enable --now xrdp

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
sudo dnf install clutter -y 

# Install Apps
sudo dnf install fastfetch -y
sudo dnf install btop -y
sudo dnf install gedit -y
sudo dnf install geany -y
sudo dnf install cmatrix -y
sudo dnf install rclone -y
sudo dnf install sxiv -y
sudo dnf install chafa -y
sudo dnf install ranger -y
sudo dnf install ncdu -y
sudo dnf install nvtop -y
sudo pipx install nvitop  

sudo dnf install caca-utils highlight atool w3m poppler-utils mediainfo -y
ranger --cmd=quit!
ranger --copy-config=all

# Speedtest
#curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
#sudo yum install speedtest


## Configure ZSH
chsh -s $(which zsh)

# Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s
oh-my-posh font install meslo

mkdir -p ~/.config/oh-my-posh/themes
curl -o ~/.config/oh-my-posh/themes/powerlevel10k_rainbow.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/powerlevel10k_rainbow.omp.json

# Zap
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
echo 'export POSH_THEME="$HOME/.config/oh-my-posh/themes/powerlevel10k_rainbow.omp.json"' >> .zshrc
echo 'plug "wintermi/zsh-oh-my-posh"' >> .zshrc
echo 'plug "wintermi/zsh-lsd"' >> .zshrc
echo 'plug "zsh-users/zsh-history-substring-search"' >> .zshrc
echo 'plug "yuhonas/zsh-aliases-lsd"' >> .zshrc
echo 'plug "Aloxaf/fzf-tab"' >> .zshrc
echo 'plug "Freed-Wu/fzf-tab-source"' >> .zshrc
echo 'plug "tm4Bit/fzf-zellij"' >> .zshrc
echo 'plug "wintermi/zsh-brew"' >> .zshrc

# Load and initialise completion system
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

# Refresh
curl -o ~/.zshrc https://raw.githubusercontent.com/Aiacos/terminal_config/refs/heads/master/.zshrc
exec zsh


## Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.zshrc
echo 'export XDG_DATA_DIRS="/home/linuxbrew/.linuxbrew/share:$XDG_DATA_DIRS"' >> ~/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install zellij
brew install jesseduffield/lazygit/lazygit
brew install jesseduffield/lazydocker/lazydocker
brew install zsh-history-substring-search
brew install atuin
brew install dust
brew install jstkdng/programs/ueberzugpp
brew install yazi ffmpegthumbnailer sevenzip jq poppler zoxide imagemagick


## Neovim setup
sudo dnf install neovim -y

# Dependencies
sudo dnf install npm nodejs cargo ripgrep fd-find fzf -y  
cargo install tree-sitter-cli
brew install bottom

# Nerd Fonts
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash  

# Go disk usage
curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
sudo chmod +x gdu_linux_amd64
sudo mv gdu_linux_amd64 /usr/bin/gdu

# AstroNvim
cd
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim +q
curl -o ~/.config/nvim/lua/community.lua https://raw.githubusercontent.com/Aiacos/AstroNvim_Config/refs/heads/master/community.lua 
nvim --headless "+MasonInstall ruff-lsp" +q  
nvim --headless "+MasonInstall pylint" +q
nvim --headless "+MasonInstall pyment" +q
# nvim --headless "+MasonInstall pylama" +q  


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
                pane name="System" command="fastfetch" {

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

# Add Snap
sudo dnf install snapd -y
sudo ln -s /var/lib/snapd/snap /snap

sudo snap install krita --classic
sudo snap install blender --classic
sudo snap install gitkraken --classic
sudo snap install pycharm-community --classic
sudo snap install obsidian --classic
sudo snap install spotify --classic

# Install Tweak
sudo dnf install gnome-tweaks -y
sudo dnf install gnome-extensions-app -y 
#pip3 install --user gnome-extensions-cli

#gext install arcmenu@arcmenu.com
gext install rocketbar@chepkun.github.com
#gnome-extensions install tiling-assistant@leleat-on-github
gext install trayIconsReloaded@selfmade.pl
gext install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gext install tophat@fflewddur.github.io
gext install blur-my-shell@aunetx

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
