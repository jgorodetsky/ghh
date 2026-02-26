#!/usr/bin/env bash
# ghh uninstaller — removes ghh and cleans up shell config
set -euo pipefail

GHH_DIR="$HOME/.ghh"

info() { printf "\033[1;34m=>\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m=>\033[0m %s\n" "$1"; }

# Remove source line from shell rc files
remove_source_line() {
  local rc_file="$1"
  if [[ -f "$rc_file" ]]; then
    if grep -qF '.ghh/bin/ghh' "$rc_file" 2>/dev/null; then
      # Remove the source line and the comment above it
      sed -i.bak '/.ghh\/bin\/ghh/d' "$rc_file"
      sed -i.bak '/# ghh — git & GitHub helper/d' "$rc_file"
      rm -f "${rc_file}.bak"
      ok "Removed from $rc_file"
    fi
  fi
}

main() {
  echo ""
  echo "  ghh uninstaller"
  echo "  ───────────────"
  echo ""

  # Remove install directory
  if [[ -d "$GHH_DIR" ]]; then
    info "Removing $GHH_DIR..."
    rm -rf "$GHH_DIR"
    ok "Removed $GHH_DIR"
  else
    info "$GHH_DIR not found, skipping."
  fi

  # Clean shell configs
  remove_source_line "$HOME/.zshrc"
  remove_source_line "$HOME/.bashrc"
  remove_source_line "$HOME/.bash_profile"

  echo ""
  echo "  ghh has been uninstalled."
  echo "  Restart your shell to complete removal."
  echo ""
}

main
