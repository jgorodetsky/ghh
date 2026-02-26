#!/usr/bin/env bash
# ghh installer — cross-platform, automatic
# Usage: curl -fsSL https://raw.githubusercontent.com/jgorodetsky/ghh/main/install.sh | bash
set -euo pipefail

GHH_REPO="jgorodetsky/ghh"
GHH_DIR="$HOME/.ghh"
SOURCE_LINE='[ -f "$HOME/.ghh/bin/ghh" ] && source "$HOME/.ghh/bin/ghh"'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { printf "\033[1;34m=>\033[0m %s\n" "$1"; }
ok()    { printf "\033[1;32m=>\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m=>\033[0m %s\n" "$1"; }
err()   { printf "\033[1;31m=>\033[0m %s\n" "$1"; exit 1; }

detect_platform() {
  case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
      else
        PLATFORM="linux"
      fi
      ;;
    *) PLATFORM="unknown" ;;
  esac
}

# ---------------------------------------------------------------------------
# Dependency installation — fully automatic
# ---------------------------------------------------------------------------

install_git() {
  if command -v git &>/dev/null; then
    ok "git found"
    return
  fi
  info "Installing git..."
  case "$PLATFORM" in
    macos)
      xcode-select --install 2>/dev/null || true
      ;;
    linux|wsl)
      if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq git
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y git
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git
      else
        err "Could not install git automatically. Install it manually and re-run."
      fi
      ;;
    *) err "Could not install git automatically. Install it manually and re-run." ;;
  esac
  command -v git &>/dev/null && ok "git installed" || err "git installation failed."
}

install_fzf() {
  if command -v fzf &>/dev/null; then
    ok "fzf found"
    return
  fi
  info "Installing fzf..."
  case "$PLATFORM" in
    macos)
      if command -v brew &>/dev/null; then
        brew install fzf
      else
        # Install directly from GitHub releases
        local tmpdir
        tmpdir=$(mktemp -d)
        local arch="darwin_amd64"
        [[ "$(uname -m)" == "arm64" ]] && arch="darwin_arm64"
        curl -fsSL "https://github.com/junegunn/fzf/releases/latest/download/fzf-${arch}.tar.gz" \
          | tar -xz -C "$tmpdir"
        sudo mv "$tmpdir/fzf" /usr/local/bin/fzf
        rm -rf "$tmpdir"
      fi
      ;;
    linux|wsl)
      if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq fzf
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y fzf
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fzf
      else
        # Install directly from GitHub releases
        local tmpdir
        tmpdir=$(mktemp -d)
        local arch="linux_amd64"
        [[ "$(uname -m)" == "aarch64" ]] && arch="linux_arm64"
        curl -fsSL "https://github.com/junegunn/fzf/releases/latest/download/fzf-${arch}.tar.gz" \
          | tar -xz -C "$tmpdir"
        sudo mv "$tmpdir/fzf" /usr/local/bin/fzf
        rm -rf "$tmpdir"
      fi
      ;;
    *) err "Could not install fzf automatically. Install it manually and re-run." ;;
  esac
  command -v fzf &>/dev/null && ok "fzf installed" || err "fzf installation failed."
}

install_gh() {
  if command -v gh &>/dev/null; then
    ok "gh found"
    return
  fi
  info "Installing gh (GitHub CLI)..."
  case "$PLATFORM" in
    macos)
      if command -v brew &>/dev/null; then
        brew install gh
      else
        # Install from GitHub releases
        local tmpdir arch="macOS_amd64"
        tmpdir=$(mktemp -d)
        [[ "$(uname -m)" == "arm64" ]] && arch="macOS_arm64"
        local latest
        latest=$(curl -fsSL "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
        curl -fsSL "https://github.com/cli/cli/releases/download/v${latest}/gh_${latest}_${arch}.zip" -o "$tmpdir/gh.zip"
        unzip -q "$tmpdir/gh.zip" -d "$tmpdir"
        sudo cp "$tmpdir"/gh_*/bin/gh /usr/local/bin/gh
        rm -rf "$tmpdir"
      fi
      ;;
    linux|wsl)
      if command -v apt-get &>/dev/null; then
        (type -p wget >/dev/null || (sudo apt-get update -qq && sudo apt-get install wget -y -qq)) \
          && sudo mkdir -p -m 755 /etc/apt/keyrings \
          && out=$(mktemp) \
          && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
          && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
          && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
             | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
          && sudo apt-get update -qq && sudo apt-get install gh -y -qq
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y gh
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm github-cli
      else
        err "Could not install gh automatically. Install it manually: https://github.com/cli/cli#installation"
      fi
      ;;
    *) err "Could not install gh automatically. Install it manually: https://github.com/cli/cli#installation" ;;
  esac
  command -v gh &>/dev/null && ok "gh installed" || err "gh installation failed."
}

# ---------------------------------------------------------------------------
# GitHub authentication — uses fzf for method selection
# ---------------------------------------------------------------------------

setup_gh_auth() {
  if ! command -v gh &>/dev/null; then
    return
  fi

  if gh auth status &>/dev/null 2>&1; then
    ok "gh is authenticated"
    return
  fi

  echo ""
  warn "gh is not logged in to GitHub."

  local method
  method=$(printf "%s\n" \
    "Browser login (recommended) @@ Opens github.com to authorize" \
    "Personal access token       @@ Paste a token you already created" \
    "Skip for now                @@ You can run 'gh auth login' later" \
    | fzf --height=6 --reverse --no-info \
          --prompt="How do you want to authenticate? > " \
    | sed 's/ *@@.*//')

  case "$method" in
    "Browser login (recommended)")
      gh auth login --hostname github.com --git-protocol https --web
      ;;
    "Personal access token"*)
      printf "  Paste your token: "
      read -rs token
      echo ""
      if [[ -n "$token" ]]; then
        echo "$token" | gh auth login --hostname github.com --git-protocol https --with-token
      else
        warn "No token provided."
      fi
      ;;
    *)
      warn "Skipping. Run 'gh auth login' when you're ready."
      return
      ;;
  esac

  if gh auth status &>/dev/null 2>&1; then
    ok "gh authenticated successfully"
  else
    warn "Authentication didn't complete. Run 'gh auth login' later."
  fi
}

# ---------------------------------------------------------------------------
# Install ghh itself
# ---------------------------------------------------------------------------

install_ghh() {
  if [[ -d "$GHH_DIR" ]]; then
    info "Updating existing installation..."
    git -C "$GHH_DIR" pull --rebase --quiet
  else
    info "Cloning ghh..."
    git clone --quiet "https://github.com/$GHH_REPO.git" "$GHH_DIR"
  fi

  chmod +x "$GHH_DIR/bin/ghh"
  ok "ghh installed to $GHH_DIR/bin/ghh"
}

# ---------------------------------------------------------------------------
# Shell integration — add source line to rc files (idempotent)
# ---------------------------------------------------------------------------

add_source_line() {
  local rc_file="$1"
  if [[ -f "$rc_file" ]]; then
    if grep -qF '.ghh/bin/ghh' "$rc_file" 2>/dev/null; then
      ok "Already in $rc_file"
    else
      printf "\n# ghh — git & GitHub helper\n%s\n" "$SOURCE_LINE" >> "$rc_file"
      ok "Added to $rc_file"
    fi
  fi
}

configure_shell() {
  local added=0

  if [[ -f "$HOME/.zshrc" ]] || command -v zsh &>/dev/null; then
    add_source_line "$HOME/.zshrc"
    added=1
  fi

  if [[ -f "$HOME/.bashrc" ]] || [[ "$SHELL" == */bash ]]; then
    add_source_line "$HOME/.bashrc"
    added=1
  fi

  if [[ "$PLATFORM" == "macos" && -f "$HOME/.bash_profile" ]]; then
    add_source_line "$HOME/.bash_profile"
  fi

  if [[ "$added" -eq 0 ]]; then
    warn "Could not detect your shell rc file."
    warn "Add this line manually:"
    warn "  $SOURCE_LINE"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  echo ""
  echo "  ghh installer"
  echo "  ─────────────"
  echo ""

  detect_platform
  info "Platform: $PLATFORM"
  echo ""

  # Install all dependencies automatically
  info "Checking dependencies..."
  install_git
  install_fzf
  install_gh

  # Authenticate with GitHub
  setup_gh_auth

  echo ""

  # Install ghh and wire up shell
  install_ghh
  configure_shell

  echo ""
  echo "  ────────────────────────────────────────"
  echo "  ghh installed successfully!"
  echo ""
  echo "  Restart your shell or run:"
  echo "    source ~/.zshrc    (or ~/.bashrc)"
  echo ""
  echo "  Then type:  ghh"
  echo "  ────────────────────────────────────────"
  echo ""
}

main
