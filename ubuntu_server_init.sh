#!/usr/bin/env bash
#
# ubuntu_server_init.sh — bootstrap for a headless Ubuntu Server 26.04 LTS.
#
# Everything comes from apt except four tools Ubuntu does not package at all
# (zellij, lazydocker, yazi, bottom) plus neovim, which come from Homebrew.
#
# Usage: bash ubuntu_server_init.sh
# Safe to re-run.

set -uo pipefail   # not -e: a single failing tool must not abort the bootstrap

# ─────────────────────────────── helpers ───────────────────────────────

FAILURES=()
log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[skip]\033[0m %s\n' "$*" >&2; FAILURES+=("$*"); }

apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" || warn "apt: $*"
}

# run_installer <url> [args…] — fetch a remote install script, then execute it.
# Never `curl … | bash`: a pipeline reports the exit status of its LAST command,
# so a failed download turns into bash reading empty input and "succeeding",
# and the piped script itself occupies bash's stdin.
run_installer() {
  local url=$1; shift
  local tmp; tmp=$(mktemp)
  if curl -fsSL -o "$tmp" "$url"; then
    bash "$tmp" "$@" </dev/null || warn "$url: installer failed"
  else
    warn "$url: download failed"
  fi
  rm -f "$tmp"
}

# Ask for sudo once, then keep the timestamp warm for the whole run. The loop
# must not be `while sudo -n true`: one transient failure would end it for good,
# and `sudo -n` cannot revive a timestamp that has already been dropped.
sudo -v || { echo "This script needs sudo."; exit 1; }
while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done &
trap 'kill %1 2>/dev/null' EXIT

# ─────────────────────────── 1. apt packages ────────────────────────────

BASE=(git gh wget curl unzip ca-certificates gnupg ruby zsh build-essential fontconfig
      net-tools openssh-server python3 python3-pip python3-full pipx)

CLI=(btop tmux rclone ranger sxiv chafa cmatrix ncdu timewarrior
     lsd bat ripgrep fd-find zoxide jq 7zip gdu
     fastfetch du-dust lazygit
     poppler-utils ffmpegthumbnailer mediainfo highlight atool w3m caca-utils)

DOCKER=(docker.io docker-compose-v2 docker-buildx containerd)

# neovim itself comes from Homebrew below (0.12 vs 0.11 on apt). brew's
# tree-sitter is the library only, so the CLI parser compiler stays on apt.
NVIM=(tree-sitter-cli nodejs npm clang clangd python3-pynvim python3-ply)

log "Updating the system"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get autoremove -y

log "Installing apt packages"
apt_install "${BASE[@]}" "${CLI[@]}" "${DOCKER[@]}" "${NVIM[@]}"

# Ubuntu ships these two under prefixed binary names; every other tool
# (yazi, fzf, nvim…) expects to find the plain names on PATH.
[ -x /usr/bin/fdfind ] && sudo ln -sfn /usr/bin/fdfind /usr/local/bin/fd
[ -x /usr/bin/batcat ] && sudo ln -sfn /usr/bin/batcat /usr/local/bin/bat

sudo systemctl enable --now ssh || warn "could not enable the ssh service"
[ -d "$HOME/.config/ranger" ] || ranger --copy-config=all

# ────────────────────────────── 2. Docker ───────────────────────────────

# Ubuntu 26.04 ships Docker 29.x as docker.io, with compose and buildx as
# separate packages — all installed above. Docker's own apt repository is
# deliberately NOT used: docker-ce conflicts with docker.io and would have to
# replace it, which buys nothing on a release this current.
log "Docker"
sudo systemctl enable --now docker || warn "could not enable the docker service"
sudo groupadd --force docker
sudo usermod -aG docker "$USER"
# No `newgrp docker` here: it spawns a subshell and would stall the script.
# The new group applies at the next login.

# ──────────────────────────────── 3. zsh ────────────────────────────────

log "Making zsh the login shell"
# Deliberately the apt zsh, not `command -v zsh`: brew shellenv is already on
# PATH by this point and would resolve to a Homebrew build, and a login shell
# should not depend on /home/linuxbrew being present and intact.
ZSH_PATH=/usr/bin/zsh
if [ ! -x "$ZSH_PATH" ]; then
  warn "$ZSH_PATH missing — login shell left unchanged"
else
  # chsh refuses any shell missing from /etc/shells — the old script checked
  # for this but never added the entry, which is why the switch never took.
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
    # `sudo chsh -s … "$USER"` works unattended; bare chsh would prompt for a password.
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

command -v atuin >/dev/null && atuin import auto >/dev/null 2>&1

# ────────────────────────── 4. Homebrew tools ───────────────────────────

# zellij, lazydocker, yazi and bottom have no apt package on 26.04, and neovim
# is newer here (0.12) than on apt (0.11). All five are in homebrew-core, so a
# plain `brew install` is enough — `brew trust` is only needed for third-party
# taps, which is how the old script pulled lazygit and lazydocker.
# Homebrew deliberately comes after every step that needs root. brew.sh runs
# `sudo --reset-timestamp` on *every* invocation ("Reset sudo timestamp to avoid
# running unauthorized sudo commands"), and its own installer additionally ends
# with `trap '/usr/bin/sudo -k' EXIT`. No amount of keeping the timestamp warm
# survives that, so instead nothing below this line calls sudo at all — which is
# also why fontconfig is in the apt list rather than in the fonts step.
log "Homebrew"
BREW=/home/linuxbrew/.linuxbrew/bin/brew
if [ ! -x "$BREW" ]; then
  FREE_GB=$(df -BG --output=avail / | tail -1 | tr -dc '0-9')
  [ "${FREE_GB:-99}" -lt 3 ] &&
    warn "only ${FREE_GB}G free on / — Homebrew needs ~1G, plus room to build lazydocker"
  export NONINTERACTIVE=1   # the installer's documented unattended switch
  run_installer https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  unset NONINTERACTIVE
fi

if [ -x "$BREW" ]; then
  eval "$("$BREW" shellenv)"
  # An earlier version of this script installed lazydocker from jesseduffield's
  # tap. homebrew-core carries it now, and brew refuses to install a formula
  # that already exists under the same name from another tap, so retire that
  # copy first — otherwise the whole install below aborts on it.
  if brew list --formula jesseduffield/lazydocker/lazydocker >/dev/null 2>&1; then
    log "Replacing the tapped lazydocker with the homebrew-core one"
    brew uninstall --force lazydocker
    brew untap jesseduffield/lazydocker
  fi

  # One formula per iteration: `brew install a b c` stops at the first failure
  # and silently skips everything after it.
  log "Installing neovim, zellij, lazydocker, yazi and bottom via Homebrew"
  for formula in atuin neovim zellij lazydocker yazi bottom; do
    brew install --yes "$formula" || warn "brew: $formula"
  done
  # The earlier, Homebrew-centric version of this script installed a dozen tools
  # that 26.04 now packages. brew's bin directory sits ahead of /usr/bin on
  # PATH, so those copies silently shadow the apt ones installed above — and you
  # end up running a different version from the one apt reports. None of them is
  # a dependency of the five kept above, so they can go.
  # atuin is deliberately NOT on this list, and not in the distro package list
  # either: its sqlite history DB applies one-way schema migrations, and an
  # older binary refuses a DB a newer one has migrated ("migration … was
  # previously applied but is missing in the resolved migrations"). Ubuntu 26.04
  # ships 18.8.0 and Fedora 44 ships 18.12.1, both older than the migrations
  # already in the DB, so downgrading to the distro build costs the entire
  # shell history. Revisit when the distros catch up.
  SUPERSEDED=(docker docker-compose dust fd ffmpegthumbnailer jq lazygit
              poppler sevenzip zoxide zsh zsh-history-substring-search)
  TO_REMOVE=()
  for formula in "${SUPERSEDED[@]}"; do
    brew list --formula "$formula" >/dev/null 2>&1 && TO_REMOVE+=("$formula")
  done
  # One call rather than one per formula: brew only refuses a removal when a
  # dependent stays behind, so removing the whole set together lets zsh go even
  # though zsh-history-substring-search requires it. Removing them one at a time
  # would depend on listing every dependent before its dependency.
  if [ ${#TO_REMOVE[@]} -gt 0 ]; then
    brew uninstall "${TO_REMOVE[@]}" || warn "brew uninstall: ${TO_REMOVE[*]}"
  fi

  # Building lazydocker pulls in the Go toolchain (~700M) purely as a build
  # dependency; autoremove drops it again once the binary exists.
  brew autoremove
  brew cleanup --prune=all
else
  warn "Homebrew unavailable — neovim, zellij, lazydocker, yazi and bottom were skipped"
fi

# ────────────────────────────── 5. AI CLIs ──────────────────────────────

log "Claude Code"
command -v claude >/dev/null || run_installer https://claude.ai/install.sh

log "claude-tui"
# Its installer aborts unless ~/.claude already exists, and Claude Code only
# creates that directory the first time it runs.
mkdir -p "$HOME/.claude"
# Its installer also prompts for a statusline mode; run_installer feeds it
# /dev/null so it takes the default instead of hanging forever. Re-run
# `claudetui setup` by hand to pick a different one.
command -v claudetui >/dev/null ||
  run_installer https://raw.githubusercontent.com/slima4/claude-tui/main/install.sh

# ──────────────────────── 6. zellij base layout ─────────────────────────

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

# ───────────────────────────── 7. AstroNvim ─────────────────────────────

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

# ──────────────────────── 8. Nerd Fonts (opt-in) ────────────────────────

# Pointless on a headless box: the fonts have to live on the machine running
# the terminal emulator. Re-run with INSTALL_FONTS=1 if this host has a display.
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

NEXT
