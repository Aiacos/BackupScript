#!/usr/bin/env bash
#
# ubuntu_init.sh — bootstrap for an Ubuntu 26.04 LTS desktop.
#
# Desktop counterpart of ubuntu_server_init.sh: same base, plus GNOME, snaps,
# themes and the grub theme. Everything comes from apt except five tools Ubuntu
# does not package (zellij, lazydocker, yazi, bottom) plus neovim, which come
# from Homebrew.
#
# Usage: bash ubuntu_init.sh
# Safe to re-run.

set -uo pipefail   # not -e: a single failing tool must not abort the bootstrap

# ─────────────────────────────── helpers ───────────────────────────────

FAILURES=()
log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[skip]\033[0m %s\n' "$*" >&2; FAILURES+=("$*"); }

apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" || warn "apt: $*"
}

# run_installer [--root|--no-tty] <url> [args…] — fetch a remote install script, run it.
# Never `curl … | bash`: a pipeline reports the exit status of its LAST command,
# so a failed download turns into bash reading empty input and "succeeding",
# and the piped script itself occupies bash's stdin, which leaves any installer
# that prompts hanging forever.
run_installer() {
  local runner=(bash)
  [ "${1:-}" = "--root" ]   && { runner=(sudo bash); shift; }
  [ "${1:-}" = "--no-tty" ] && { runner=(setsid -w bash); shift; }
  local url=$1; shift
  local tmp; tmp=$(mktemp)
  if curl -fsSL -o "$tmp" "$url"; then
    "${runner[@]}" "$tmp" "$@" </dev/null || warn "$url: installer failed"
  else
    warn "$url: download failed"
  fi
  rm -f "$tmp"
}

# Ask for sudo once, then keep the timestamp warm. The loop must not be
# `while sudo -n true`: one transient failure would end it for good.
sudo -v || { echo "This script needs sudo."; exit 1; }
while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done &
trap 'kill %1 2>/dev/null' EXIT

# ══════════════════════════ WHAT GETS INSTALLED ══════════════════════════
#
# This block is the only part you need to edit. Add a name to the right list
# and re-run the script — everything below reads these lists and nothing else.
#
#   APT_*      packages from Ubuntu       apt-get install
#   BREW_*     Homebrew formulae          only for what Ubuntu does not package
#   SNAP       snap packages              installed with --classic
#   GNOME_EXT  GNOME shell extensions     installed and enabled with gext
#
# Where does a new tool belong? `apt-cache policy <name>` answers it: if apt
# has a candidate, put it in APT_CLI (or APT_DESKTOP for GUI apps). Reach for
# BREW_FORMULAE only when apt has nothing, and say why in a comment.

APT_BASE=(git gh wget curl unzip ca-certificates gnupg ruby zsh build-essential
          fontconfig net-tools openssh-server python3 python3-pip python3-full
          pipx)

APT_CLI=(btop tmux rclone ranger sxiv chafa cmatrix ncdu timewarrior
         lsd bat ripgrep fd-find zoxide jq 7zip gdu imagemagick
         fastfetch du-dust lazygit
         poppler-utils ffmpegthumbnailer mediainfo highlight atool w3m caca-utils)

APT_DESKTOP=(gedit geany gnome-tweaks gnome-shell-extensions
             gnome-shell-extension-manager numix-icon-theme node-typescript make)

APT_DOCKER=(docker.io docker-compose-v2 docker-buildx containerd)

# neovim itself comes from Homebrew (0.12 there vs 0.11 on apt). brew's
# tree-sitter is the library only, so the CLI parser compiler stays on apt.
APT_NVIM=(tree-sitter-cli nodejs npm clang clangd python3-pynvim python3-ply)

# Not packaged by Ubuntu 26.04 at all, plus neovim for the newer release.
# atuin is here for a different reason: its sqlite history DB applies one-way
# schema migrations, so the older apt build refuses a DB a newer binary has
# already migrated, costing the whole shell history.
BREW_FORMULAE=(atuin neovim zellij lazydocker yazi bottom)

SNAP=(krita blender gitkraken pycharm-community spotify)

GNOME_EXT=(arcmenu@arcmenu.com
           appindicatorsupport@rgcjonas.gmail.com
           tophat@fflewddur.github.io
           workspace-indicator@gnome-shell-extensions.gcampax.github.com
           blur-my-shell@aunetx)

# ─────────────────────────── 1. apt packages ────────────────────────────

log "Updating the system"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get autoremove -y

log "Installing apt packages"
apt_install "${APT_BASE[@]}" "${APT_CLI[@]}" "${APT_DESKTOP[@]}" \
           "${APT_DOCKER[@]}" "${APT_NVIM[@]}"

# Ubuntu ships these two under prefixed binary names; every other tool
# (yazi, fzf, nvim…) expects to find the plain names on PATH.
[ -x /usr/bin/fdfind ] && sudo ln -sfn /usr/bin/fdfind /usr/local/bin/fd
[ -x /usr/bin/batcat ] && sudo ln -sfn /usr/bin/batcat /usr/local/bin/bat

# atuin comes from Homebrew (see the Homebrew section): the distro build is
# older than the schema migrations already in ~/.local/share/atuin/history.db
# and would refuse to open it. Drop the apt copy an earlier version of this
# script may have installed, so the two cannot shadow each other.
dpkg -s atuin >/dev/null 2>&1 &&
  sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y atuin

sudo systemctl enable --now ssh || warn "could not enable the ssh service"
[ -d "$HOME/.config/ranger" ] || ranger --copy-config=all

# ────────────────────────── 2. Docker and CasaOS ────────────────────────

# Ubuntu 26.04 ships Docker 29.x as docker.io, with compose and buildx as
# separate packages — all installed above. Docker's own apt repository is
# deliberately NOT used: docker-ce conflicts with docker.io.
log "Docker"
sudo systemctl enable --now docker || warn "could not enable the docker service"
sudo groupadd --force docker
sudo usermod -aG docker "$USER"
# No `newgrp docker` here: it spawns a subshell and would stall the script.
# The new group applies at the next login.

log "CasaOS"
command -v casaos >/dev/null || run_installer --root https://get.casaos.io

# ───────────────────────────── 3. Snap apps ─────────────────────────────

log "Snap"
apt_install snapd
[ -e /snap ] || sudo ln -s /var/lib/snapd/snap /snap
for app in "${SNAP[@]}"; do
  snap list "$app" >/dev/null 2>&1 || sudo snap install "$app" --classic || warn "snap: $app"
done

# ──────────────────────────── 4. Grub theme ─────────────────────────────

log "Grub theme"
mkdir -p "$HOME/.settings"
if [ ! -d "$HOME/.settings/grub2-themes" ]; then
  git clone https://github.com/vinceliuice/grub2-themes.git "$HOME/.settings/grub2-themes" &&
    sudo "$HOME/.settings/grub2-themes/install.sh" -b -t tela || warn "grub theme install failed"
fi

# ──────────────────────────────── 5. zsh ────────────────────────────────

log "Making zsh the login shell"
# Deliberately the apt zsh, not `command -v zsh`: brew shellenv goes on PATH
# further down and would resolve to a Homebrew build, and a login shell should
# not depend on /home/linuxbrew being present and intact.
ZSH_PATH=/usr/bin/zsh
if [ ! -x "$ZSH_PATH" ]; then
  warn "$ZSH_PATH missing — login shell left unchanged"
else
  # chsh refuses any shell missing from /etc/shells — the old script checked
  # for this but never added the entry, which is why the switch never took.
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
    # `sudo chsh -s … "$USER"` works unattended; bare chsh would prompt.
    sudo chsh -s "$ZSH_PATH" "$USER" || warn "chsh failed: sudo chsh -s $ZSH_PATH $USER"
  fi
fi

# oh-my-posh, claude and claudetui all install into ~/.local/bin. Ubuntu adds
# that to PATH from ~/.profile, which zsh never reads — so put it in ~/.zprofile,
# which zsh does read at login and which the .zshrc download below leaves alone.
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
touch "$HOME/.zprofile"
grep -qxF "$PATH_LINE" "$HOME/.zprofile" || printf '%s\n' "$PATH_LINE" >> "$HOME/.zprofile"
export PATH="$HOME/.local/bin:$PATH"

log "Oh My Posh"
# Its installer refuses to create the target directory: "Directory … does not
# exist, set a different directory and try again."
mkdir -p "$HOME/.local/bin"
command -v oh-my-posh >/dev/null ||
  run_installer https://ohmyposh.dev/install.sh -d "$HOME/.local/bin"
mkdir -p "$HOME/.config/oh-my-posh/themes"
curl -fsSL -o "$HOME/.config/oh-my-posh/themes/powerlevel10k_rainbow.omp.json" \
  https://raw.githubusercontent.com/Aiacos/terminal_config/refs/heads/master/powerlevel10k_rainbow_lucifer.omp.json ||
  warn "oh-my-posh theme download failed"

# The shared .zshrc is the single source of truth and overwrites whatever is
# here. It already carries Zap's `source …/zap.zsh` line, the plug list and the
# `brew shellenv` eval, so it has to land BEFORE Zap runs: install.zsh ends with
# `source "${ZDOTDIR:-$HOME}/.zshrc"` and returns non-zero when that file does
# not exist yet — which on a fresh machine it does not. (The original script had
# the opposite problem: it fetched the file *after* appending its own plugin
# lines, so the download silently wiped every line it had just written.)
log "Fetching the shared .zshrc"
curl -fsSL -o "$HOME/.zshrc" \
  https://raw.githubusercontent.com/Aiacos/terminal_config/refs/heads/master/.zshrc ||
  warn ".zshrc download failed"

log "Zap (zsh plugin manager)"
# --keep leaves the .zshrc just downloaded alone; without it Zap renames it and
# writes its own template in its place.
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] ||
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
      --branch release-v1 --keep || warn "zap install failed"


# ────────────────────────── 6. Homebrew tools ───────────────────────────

# zellij, lazydocker, yazi and bottom have no apt package on 26.04, and neovim
# is newer here (0.12) than on apt (0.11). All five are in homebrew-core, so a
# plain `brew install` is enough — `brew trust` is only needed for third-party
# taps, which is how the old script pulled lazygit and lazydocker.
#
# Homebrew deliberately comes after every step that needs root. brew.sh runs
# `sudo --reset-timestamp` on *every* invocation ("Reset sudo timestamp to avoid
# running unauthorized sudo commands"), and its own installer additionally ends
# with `trap '/usr/bin/sudo -k' EXIT`. No amount of keeping the timestamp warm
# survives that, so instead nothing below this line calls sudo at all — which is
# also why fontconfig and snapd are in the apt section rather than down here.
log "Homebrew"
BREW_BIN=/home/linuxbrew/.linuxbrew/bin/brew
if [ ! -x "$BREW_BIN" ]; then
  export NONINTERACTIVE=1   # the installer's documented unattended switch
  run_installer https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  unset NONINTERACTIVE
fi

if [ -x "$BREW_BIN" ]; then
  eval "$("$BREW_BIN" shellenv)"

  # An earlier version of this script installed lazygit and lazydocker from
  # jesseduffield's taps. homebrew-core carries both now, and brew refuses to
  # install a formula that already exists under the same name from another tap,
  # so retire those copies first — otherwise the install below aborts on them.
  for tapped in jesseduffield/lazydocker/lazydocker jesseduffield/lazygit/lazygit; do
    if brew list --formula "$tapped" >/dev/null 2>&1; then
      log "Replacing the tapped ${tapped##*/}"
      brew uninstall --force "${tapped##*/}"
      brew untap "${tapped%/*}"
    fi
  done

  # One formula per iteration: `brew install a b c` stops at the first failure
  # and silently skips everything after it.
  log "Installing neovim, zellij, lazydocker, yazi and bottom via Homebrew"
  for formula in "${BREW_FORMULAE[@]}"; do
    brew install --yes "$formula" || warn "brew: $formula"
  done

  # Nothing else is installed through Homebrew on purpose: its bin directory
  # precedes /usr/bin on PATH, so a formula that the distro also packages would
  # silently shadow the distro build — you would run a different version from
  # the one the package manager reports. If an older, Homebrew-centric version
  # of this script left such duplicates on a machine, remove them by hand:
  #   brew uninstall docker docker-compose dust fd jq lazygit zoxide zsh

  # Building lazydocker pulls in the Go toolchain (~700M) purely as a build
  # dependency; autoremove drops it again once the binary exists.
  brew autoremove
  brew cleanup --prune=all
else
  warn "Homebrew unavailable — neovim, zellij, lazydocker, yazi and bottom were skipped"
fi

# atuin only exists from here on — it is installed by Homebrew above, not by the
# distro — so its one-time import of the pre-existing shell history has to run
# after that section, not in the zsh one where it used to sit.
command -v atuin >/dev/null && atuin import auto >/dev/null 2>&1

# ────────────────────────────── 7. AI CLIs ──────────────────────────────

log "Claude Code"
command -v claude >/dev/null || run_installer https://claude.ai/install.sh

log "claude-tui"
# Two quirks of its installer:
#  - it aborts unless ~/.claude already exists, and Claude Code only creates
#    that directory the first time it actually runs;
#  - it asks for a statusline mode with `read -rn1 mode_choice < /dev/tty`,
#    reading straight from the controlling terminal, so redirecting stdin has
#    no effect at all and it blocks forever when nobody is there to type.
# --no-tty runs it under setsid, in a new session with no controlling terminal:
# the read fails, the installer falls back to mode_choice="" and its own
# `case "${mode_choice}" in 1|"")` maps that to "full" — option 1, which is the
# mode we want. Verified below rather than assumed.
mkdir -p "$HOME/.claude"
command -v claudetui >/dev/null ||
  run_installer --no-tty https://raw.githubusercontent.com/slima4/claude-tui/main/install.sh

# "full" writes `claudetui statusline`; "compact" would append --compact.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ] && grep -q '"claudetui statusline"' "$CLAUDE_SETTINGS"; then
  printf '    statusline mode: full\n'
elif [ -f "$CLAUDE_SETTINGS" ] && grep -q 'claudetui statusline' "$CLAUDE_SETTINGS"; then
  warn "claude-tui statusline is not in full mode — run: claudetui setup"
fi

# ──────────────────────── 8. zellij base layout ─────────────────────────

# This used to live after `exec zsh`, which replaces the shell process, so it
# never ran at all. It also used `tee -a`, which appended a second copy of the
# layout on every re-run; `cat >` rewrites it instead.
log "Zellij base layout"
ZELLIJ_LAYOUT="$HOME/.zellij_base_layout.kdl"
cat > "$ZELLIJ_LAYOUT" <<'KDL'
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
            pane name="Btop" command="btop"
            pane split_direction="Horizontal" {
                pane name="System" command="fastfetch" {
                    args "--config" "paleofetch.jsonc"
                }
                pane focus=true name="Shell"
            }
        }
    }
}

session_name "Base"
attach_to_session true
pane_frames true
pane_frame_style "full"
KDL

# zellij only auto-discovers layouts inside its own layouts/ directory, so point
# default_layout at this one by absolute path — that makes a bare `zellij` open
# it. Nothing already in config.kdl is touched.
ZELLIJ_CONFIG="$HOME/.config/zellij/config.kdl"
mkdir -p "$(dirname "$ZELLIJ_CONFIG")"
touch "$ZELLIJ_CONFIG"
grep -qE '^[[:space:]]*default_layout' "$ZELLIJ_CONFIG" ||
  echo "default_layout \"$ZELLIJ_LAYOUT\"" >> "$ZELLIJ_CONFIG"

# ───────────────────────────── 9. AstroNvim ─────────────────────────────

log "AstroNvim"
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone --depth 1 https://github.com/AstroNvim/template "$HOME/.config/nvim" &&
    rm -rf "$HOME/.config/nvim/.git"
fi
curl -fsSL -o "$HOME/.config/nvim/lua/community.lua" \
  https://raw.githubusercontent.com/Aiacos/AstroNvim_Config/refs/heads/master/community.lua ||
  warn "community.lua download failed"
nvim --headless "+Lazy! sync" +qa 2>/dev/null
for tool in ruff pylint pyment mypy; do
  nvim --headless "+MasonInstall $tool" +qa 2>/dev/null || warn "mason: $tool"
done

# ──────────────────────── 10. GNOME and theming ─────────────────────────

# `gext` comes from gnome-extensions-cli, which the old script left commented
# out while still calling gext a dozen times below — every one of those failed
# with "command not found".
log "GNOME extensions"
command -v gext >/dev/null || {
  pipx install gnome-extensions-cli --system-site-packages || warn "gext install failed"
  pipx ensurepath
}
# The venv sees system site-packages, so pip skips any dependency the distro
# happened to ship at install time. When that package later disappears gext
# dies on import. Inject the missing piece into the venv so it no longer
# depends on the system copy.
if command -v gext >/dev/null && ! gext --version >/dev/null 2>&1; then
  pipx inject gnome-extensions-cli typing_extensions || warn "gext venv repair failed"
fi

if command -v gext >/dev/null; then
  for ext in "${GNOME_EXT[@]}"; do
    # --filesystem unpacks straight into ~/.local/share/gnome-shell/extensions.
    # The default D-Bus path asks GNOME Shell to install, which pops a
    # confirmation dialog on screen and silently does nothing unattended.
    gext --filesystem install "$ext" || warn "gext: $ext"
  done
fi

# gsettings needs a live session bus; over SSH it has nothing to talk to.
if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  log "Theming"
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'
else
  warn "no session bus — skipped gsettings (run this from a desktop session)"
fi

# ─────────────────────── 11. Wallpapers and Pop Shell ───────────────────

log "Dracula wallpapers"
[ -d "$HOME/.settings/wallpaper" ] ||
  git clone https://github.com/dracula/wallpaper.git "$HOME/.settings/wallpaper"

log "Pop Shell"
if [ ! -d "$HOME/.settings/shell" ]; then
  git clone https://github.com/pop-os/shell.git "$HOME/.settings/shell" &&
    make -C "$HOME/.settings/shell" local-install || warn "pop-shell install failed"
fi

# ──────────────────────── 12. Nerd Fonts (opt-in) ───────────────────────

if [ "${INSTALL_FONTS:-0}" = 1 ]; then
  log "Nerd Fonts"
  run_installer https://raw.githubusercontent.com/getnf/getnf/main/install.sh
  oh-my-posh font install meslo
fi

# ─────────────────────────────── summary ────────────────────────────────

log "Done"
if [ ${#FAILURES[@]} -gt 0 ]; then
  printf '\033[1;33mSteps that did not complete:\033[0m\n'
  printf '  - %s\n' "${FAILURES[@]}"
fi
cat <<'NEXT'

Log out and back in to pick up the zsh login shell and the docker group, then:
  echo $SHELL                    # /usr/bin/zsh
  docker run --rm hello-world    # no sudo needed
  zellij                         # opens ~/.zellij_base_layout.kdl
  claudetui setup                # only to change the statusline mode

GNOME extensions need a session restart (log out and back in on Wayland).

NEXT
