#!/usr/bin/env bash
#
# fedora_init.sh — bootstrap for a Fedora 44 workstation.
#
# Everything comes from dnf except six tools Fedora does not package at all
# (zellij, lazygit, lazydocker, yazi, bottom, dust), which come from Homebrew.
# Unlike the Ubuntu scripts, neovim is NOT one of them: Fedora 44 ships 0.12.5,
# the same version Homebrew has.
#
# Usage: bash fedora_init.sh
# Safe to re-run.

set -uo pipefail   # not -e: a single failing tool must not abort the bootstrap

# ─────────────────────────────── helpers ───────────────────────────────

FAILURES=()
log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[skip]\033[0m %s\n' "$*" >&2; FAILURES+=("$*"); }

dnf_install() { sudo dnf install -y "$@" || warn "dnf: $*"; }

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

FEDORA_VER=$(rpm -E %fedora)

# ══════════════════════════ WHAT GETS INSTALLED ══════════════════════════
#
# This block is the only part you need to edit. Add a name to the right list
# and re-run the script — everything below reads these lists and nothing else.
#
#   DNF_*      packages from Fedora       dnf install
#   BREW_*     Homebrew formulae          only for what Fedora does not package
#   SNAP       snap packages              installed with --classic
#   GNOME_EXT  GNOME shell extensions     installed AND enabled with gext
#
# Where does a new tool belong? `dnf info <name>` answers it: if Fedora has it,
# put it in DNF_CLI (or DNF_DESKTOP for GUI apps). Reach for BREW_FORMULAE only
# when Fedora has nothing, and say why in a comment.
#
# Package names that differ from the obvious guess on Fedora 44:
#   wget -> wget2-wget, python3-pynvim -> python3-neovim, p7zip -> 7zip.

DNF_BASE=(git gh curl wget2-wget unzip zsh lsd pipx
          python3 python3-pip python3-neovim python3-ply
          openssh-server btrfs-assistant)

DNF_DEV=(mpfr-devel gmp-devel libmpc-devel zlib-devel glibc-devel glibc-devel.i686
         isl-devel gcc gcc-c++ gcc-gnat gcc-gdc libgphobos-static cmake
         mesa-libGL-devel clang clangd)

DNF_CLI=(fastfetch btop gedit geany cmatrix cava seafile-client rclone sxiv chafa
         ranger ncdu nvtop timew zoxide jq 7zip gdu ripgrep fd-find fzf
         tree-sitter-cli neovim nodejs npm
         caca-utils highlight atool w3m poppler-utils mediainfo ffmpegthumbnailer)

DNF_DESKTOP=(gnome-tweaks gnome-extensions-app gnome-shell-extension-pop-shell
             clutter gnome-shell-extension-blur-my-shell
             gnome-shell-extension-workspace-indicator
             mint-y-icons numix-icon-theme numix-icon-theme-circle
             yaru-theme papirus-icon-theme)

DNF_NVIDIA=(akmod-nvidia xorg-x11-drv-nvidia-cuda)

DNF_WM=(niri noctalia)

# Not packaged by stock Fedora 44. (zellij, yazi and bottom exist in the
# third-party Terra repo, but that is not enabled on a fresh install.) atuin is
# here for a different reason: its sqlite history DB applies one-way schema
# migrations, so Fedora's older build refuses a DB a newer binary has already
# migrated, costing the whole shell history. neovim is NOT here — Fedora 44
# ships 0.12.5, the same version Homebrew has.
BREW_FORMULAE=(atuin zellij lazygit lazydocker yazi bottom dust)

SNAP=(krita blender gitkraken pycharm-community obsidian spotify termius-app)

# Installed with `gext install`, then enabled when a session bus is available.
GNOME_EXT=(arcmenu@arcmenu.com
           rocketbar@chepkun.github.com
           trayIconsReloaded@selfmade.pl
           tophat@fflewddur.github.io
           workspace-indicator@gnome-shell-extensions.gcampax.github.com
           blur-my-shell@aunetx
           panel-corners@aunetx
           openbar@neuromorph
           dash2dock-lite@icedman.github.com)

# ─────────────────────────── 1. dnf packages ────────────────────────────

log "Updating the system"
sudo dnf upgrade -y   # `dnf update` is just an alias for upgrade

log "Development groups"
# dnf5 (Fedora 41+) dropped `groupinstall`; it is `group install` now, and the
# old form fails with: unknown argument "groupinstall".
sudo dnf group install -y c-development development-tools || warn "dnf group install"

log "Installing dnf packages"
dnf_install "${DNF_BASE[@]}" "${DNF_DEV[@]}" "${DNF_CLI[@]}" "${DNF_DESKTOP[@]}"

# atuin comes from Homebrew (see the Homebrew section): the distro build is
# older than the schema migrations already in ~/.local/share/atuin/history.db
# and would refuse to open it. Drop the dnf copy an earlier version of this
# script may have installed, so the two cannot shadow each other.
rpm -q atuin >/dev/null 2>&1 && sudo dnf remove -y atuin

sudo systemctl enable --now sshd || warn "could not enable sshd"
[ -d "$HOME/.config/ranger" ] || ranger --copy-config=all

log "nvitop"
# `sudo pipx install` would drop this into root's home, where the user cannot
# reach it. pipx is per-user by design.
command -v nvitop >/dev/null || pipx install nvitop || warn "nvitop install failed"

# ──────────────────────── 2. RPM Fusion and NVIDIA ──────────────────────

# akmod-nvidia lives in RPM Fusion nonfree, which the old script never enabled —
# so the NVIDIA install silently did nothing on a fresh system.
log "RPM Fusion"
dnf_install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

log "NVIDIA driver"
dnf_install "${DNF_NVIDIA[@]}"

# ───────────────────────────── 3. Snap apps ─────────────────────────────

log "Snap"
dnf_install snapd
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

# ───────────────────────── 5. Window managers ───────────────────────────

log "Niri"
dnf_install "${DNF_WM[@]}"
# The old script had `systemctl --user add-wants niri.service`, which fails with
# "Too few arguments": the syntax is `add-wants TARGET UNIT...`, so niri.service
# is the target and the unit to attach to it is missing. niri ships only
# niri.service and niri-shutdown.target, and the noctalia package ships no unit
# at all, so there is no way to tell which unit was meant. Fill in the blank and
# uncomment, e.g.:
#   systemctl --user add-wants niri.service xdg-desktop-portal-gnome.service
warn "niri: 'systemctl --user add-wants niri.service <UNIT>' left commented out, unit unknown"

# ──────────────────────────────── 6. zsh ────────────────────────────────

# The old script never installed zsh at all, yet called `chsh -s $(which zsh)`.
# It only ever worked because `brew install zsh-history-substring-search` pulled
# in Homebrew's zsh as a dependency — so the login shell silently became a brew
# build. zsh is in the dnf list above now.
log "Making zsh the login shell"
ZSH_PATH=/usr/bin/zsh
if [ ! -x "$ZSH_PATH" ]; then
  warn "$ZSH_PATH missing — login shell left unchanged"
else
  # chsh refuses any shell missing from /etc/shells.
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$USER" || warn "chsh failed: sudo chsh -s $ZSH_PATH $USER"
  fi
fi

# oh-my-posh, claude and claudetui install into ~/.local/bin. zsh does not read
# ~/.profile, so put the PATH entry in ~/.zprofile, which zsh does read at login
# and which the .zshrc download below leaves alone.
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


# ────────────────────────── 7. Homebrew tools ───────────────────────────

# What stock Fedora 44 has no package for. (zellij, yazi and bottom exist in the
# third-party Terra repo, but that is not enabled on a fresh install, and adding
# a whole repo for three binaries is not worth it when brew is here anyway.)
#
# Homebrew deliberately comes after every step that needs root. brew.sh runs
# `sudo --reset-timestamp` on *every* invocation ("Reset sudo timestamp to avoid
# running unauthorized sudo commands"), and its own installer additionally ends
# with `trap '/usr/bin/sudo -k' EXIT`. No amount of keeping the timestamp warm
# survives that, so nothing below this line calls sudo at all.
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
  # install a formula that already exists under the same name from another tap.
  for tapped in jesseduffield/lazydocker/lazydocker jesseduffield/lazygit/lazygit; do
    if brew list --formula "$tapped" >/dev/null 2>&1; then
      log "Replacing the tapped ${tapped##*/}"
      brew uninstall --force "${tapped##*/}"
      brew untap "${tapped%/*}"
    fi
  done

  # One formula per iteration: `brew install a b c` stops at the first failure
  # and silently skips everything after it.
  log "Installing zellij, lazygit, lazydocker, yazi, bottom and dust via Homebrew"
  for formula in "${BREW_FORMULAE[@]}"; do
    brew install --yes "$formula" || warn "brew: $formula"
  done

  # Fedora 44 packages these, and brew's bin directory sits ahead of /usr/bin on
  # PATH, so brew copies would silently shadow the dnf ones installed above.
  # Nothing else is installed through Homebrew on purpose: its bin directory
  # precedes /usr/bin on PATH, so a formula that Fedora also packages would
  # silently shadow the dnf build — you would run a different version from the
  # one rpm reports. If an older, Homebrew-centric version of this script left
  # such duplicates on a machine, remove them by hand:
  #   brew uninstall ffmpegthumbnailer imagemagick jq neovim poppler sevenzip \
  #                  zoxide zsh zsh-history-substring-search

  brew autoremove
  brew cleanup --prune=all
else
  warn "Homebrew unavailable — zellij, lazygit, lazydocker, yazi, bottom, dust skipped"
fi

# atuin only exists from here on — it is installed by Homebrew above, not by the
# distro — so its one-time import of the pre-existing shell history has to run
# after that section, not in the zsh one where it used to sit.
command -v atuin >/dev/null && atuin import auto >/dev/null 2>&1

# ────────────────────────────── 8. AI CLIs ──────────────────────────────

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

# ──────────────────────── 9. zellij base layout ─────────────────────────

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

# ──────────────────────────── 10. AstroNvim ─────────────────────────────

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

# ──────────────────────── 11. GNOME and theming ─────────────────────────

# `gext` comes from gnome-extensions-cli, which the old script left commented
# out while still calling gext nine times below — every one of those failed with
# "command not found".
log "GNOME extensions"
command -v gext >/dev/null || {
  pipx install gnome-extensions-cli --system-site-packages || warn "gext install failed"
  pipx ensurepath
}

if command -v gext >/dev/null; then
  for ext in "${GNOME_EXT[@]}"; do
    gext install "$ext" || warn "gext: $ext"
  done
fi

# gsettings and `gnome-extensions enable` need a live session bus; over SSH they
# have nothing to talk to.
if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  log "Theming"
  for ext in "${GNOME_EXT[@]}"; do
    gnome-extensions enable "$ext" 2>/dev/null || warn "enable: $ext"
  done
  gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
else
  warn "no session bus — skipped gsettings and extension enabling"
fi

# ─────────────────────── 12. Wallpapers, Nerd Fonts ─────────────────────

log "Dracula wallpapers"
[ -d "$HOME/.settings/wallpaper" ] ||
  git clone https://github.com/dracula/wallpaper.git "$HOME/.settings/wallpaper"

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

Reboot to load the NVIDIA akmod, then log in again to pick up the zsh shell:
  echo $SHELL                    # /usr/bin/zsh
  modinfo -F version nvidia      # akmod built against the running kernel
  zellij                         # opens ~/.zellij_base_layout.kdl
  claudetui setup                # only to change the statusline mode

NEXT
