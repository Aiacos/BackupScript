# Update
sudo pacman -Syu --noconfirm

# Install Software
sudo pacman -S --noconfirm neofetch
sudo pacman -S --noconfirm btop
sudo pacman -S --noconfirm cmatrix
sudo pacman -S --noconfirm tmux

sudo pacman -S --noconfirm opera
sudo pacman -S --noconfirm blender
sudo pacman -S --noconfirm krita

# Install Develpment Tools
sudo pacman -S --noconfirm base-devel
sudo pacman -S --noconfirm pycharm-community-edition
flatpak install flathub com.axosoft.GitKraken -y


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