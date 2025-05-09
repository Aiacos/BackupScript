## Update
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

## Dev Tools
sudo apt install git wget curl ruby zsh lsd -y
sudo apt install build-essential -y
sudo apt install net-tools -y
sudo apt install python3 python3-pip pipx -y

## Configure SSH
sudo apt install openssh-server -y

## Install Apps
sudo apt install fastfetch -y
sudo apt install btop -y
sudo apt install gedit -y
sudo apt install geany -y
sudo apt install tmux -y
sudo apt install rclone -y
sudo apt install ranger -y
sudo apt install sxiv -y
sudo apt install chafa -y
sudo apt install cmatrix -y
sudo apt install ncdu -y
sudo apt install gnome-tweaks -y
sudo apt install gnome-shell-extension-manager -y

sudo apt install caca-utils highlight atool w3m poppler-utils mediainfo -y
ranger --cmd=quit!
ranger --copy-config=all

## CasaOS
curl -fsSL https://get.casaos.io | sudo bash
sudo groupadd docker
sudo usermod -aG docker $USER

## Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo 'export XDG_DATA_DIRS="/home/linuxbrew/.linuxbrew/share:$XDG_DATA_DIRS"' >> ~/.zshrc

brew install zellij
brew install jesseduffield/lazygit/lazygit
brew install jesseduffield/lazydocker/lazydocker
brew install zsh-history-substring-search
brew install atuin
brew install dust
brew install jstkdng/programs/ueberzugpp
brew install yazi ffmpegthumbnailer sevenzip jq poppler fd zoxide imagemagick

## Configure ZSH
chsh -s $(which zsh)

# Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s
oh-my-posh font install meslo

mkdir -p ~/.config/oh-my-posh/themes
curl -o ~/.config/oh-my-posh/themes/powerlevel10k_rainbow.omp.json https://raw.githubusercontent.com/Aiacos/terminal_config/refs/heads/master/powerlevel10k_rainbow_lucifer.omp.json

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
                        args "--config" "paleofetch.jsonc"
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

## Neovim setup
brew install neovim

# Dependencies
sudo apt install npm nodejs cargo ripgrep fd-find clang clangd -y  
sudo apt install pipx python3-full python3-pynvim python3-ply -y  
cargo install tree-sitter-cli
brew install bottom

# Go disk usage
curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
sudo chmod +x gdu_linux_amd64
sudo mv gdu_linux_amd64 /usr/bin/gdu

# Nerd Fonts
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash  

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


## Settings Folder
cd
mkdir .settings

# Dracula Wallpaper
cd
cd .settings
git clone https://github.com/dracula/wallpaper.git
cd 

## Grub
cd 
cd .settings
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -b -t tela
cd


# Add Snap
sudo apt install snapd -y
sudo ln -s /var/lib/snapd/snap /snap

sudo snap install krita --classic
sudo snap install blender --classic
sudo snap install gitkraken --classic
sudo snap install pycharm-community --classic
#sudo snap install obsidian --classic
sudo snap install spotify --classic

## Add Flatpack
#sudo apt install flatpak -y
#sudo apt install gnome-software-plugin-flatpak -y
#flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#sudo flatpak install flathub com.anydesk.Anydesk -y
#sudo flatpak install flathub org.blender.Blender -y
#sudo flatpak install flathub org.kde.krita -y
#sudo flatpak install flathub com.axosoft.GitKraken -y
#sudo flatpak install flathub com.jetbrains.PyCharm-Community -y
#sudo flatpak install flathub org.gnome.Builder -y
#sudo flatpak install flathub nz.mega.MEGAsync -y


## Install Tweak
sudo apt install gnome-tweaks gnome-shell-extensions -y
pipx install gnome-extensions-cli --system-site-packages
pipx ensurepath 

gext install arcmenu@arcmenu.com
gext install rocketbar@chepkun.github.com
gext install trayIconsReloaded@selfmade.pl
gext install workspace-indicator@gnome-shell-extensions.gcampax.github.com
gext install tophat@fflewddur.github.io
gext install blur-my-shell@aunetx

#gnome-extensions enable arcmenu@arcmenu.com
#gnome-extensions enable rocketbar@chepkun.github.com
#gnome-extensions enable trayIconsReloaded@selfmade.pl
#gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
#gnome-extensions enable tophat@fflewddur.github.io
#gnome-extensions enable blur-my-shell@aunetx

cd

sudo apt install numix-icon-theme numix-icon-theme-square -y 

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
#gsettings set org.gnome.desktop.interface icon-theme 'Numix-Square'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'

# PoP Shell
sudo apt install git node-typescript make -y
git clone https://github.com/pop-os/shell.git
cd shell
make local-install
cd 
