#!/usr/bin/env bash
# release.sh — Automate ghh releases
# Usage: ./release.sh <version>
# Example: ./release.sh 0.3.0

set -euo pipefail

# -------------------------------------------------------------------------
# Config
# -------------------------------------------------------------------------

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TAP_DIR="${GHH_TAP_DIR:-$HOME/code/homebrew-ghh}"
GITHUB_REPO="jgorodetsky/ghh"

# -------------------------------------------------------------------------
# Validate
# -------------------------------------------------------------------------

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh 0.3.0"
  exit 1
fi

# Strip leading v if provided (we add it ourselves)
VERSION="${VERSION#v}"

if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) is required."; exit 1
fi

if [[ ! -d "$TAP_DIR" ]]; then
  echo "Error: Homebrew tap repo not found at $TAP_DIR"
  echo "Set GHH_TAP_DIR to the correct path."
  exit 1
fi

cd "$REPO_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: Working tree is dirty. Commit or stash changes first."
  exit 1
fi

if git rev-parse "v$VERSION" &>/dev/null; then
  echo "Error: Tag v$VERSION already exists."
  exit 1
fi

CURRENT_VERSION=$(grep 'GHH_VERSION=' bin/ghh | head -1 | sed 's/.*"\(.*\)"/\1/')
echo ""
echo "  Current version: $CURRENT_VERSION"
echo "  New version:     $VERSION"
echo ""
printf "Proceed? [y/N]: "; read -r confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0

# -------------------------------------------------------------------------
# Step 1: Bump version in bin/ghh
# -------------------------------------------------------------------------

echo ""
echo "[1/6] Bumping version in bin/ghh..."
sed -i '' "s/GHH_VERSION=\".*\"/GHH_VERSION=\"$VERSION\"/" bin/ghh

# -------------------------------------------------------------------------
# Step 2: Update Homebrew formula URL (SHA256 placeholder for now)
# -------------------------------------------------------------------------

echo "[2/6] Updating Homebrew formula URL..."
sed -i '' "s|archive/refs/tags/v.*\.tar\.gz|archive/refs/tags/v$VERSION.tar.gz|" homebrew/ghh.rb
sed -i '' "s/sha256 \".*\"/sha256 \"PLACEHOLDER\"/" homebrew/ghh.rb

# -------------------------------------------------------------------------
# Step 3: Commit, tag, push
# -------------------------------------------------------------------------

echo "[3/6] Committing and pushing..."
git add bin/ghh homebrew/ghh.rb
git commit -m "chore: bump version to v$VERSION"
git tag "v$VERSION"
git push
git push origin "v$VERSION"

# -------------------------------------------------------------------------
# Step 4: Create GitHub release
# -------------------------------------------------------------------------

echo "[4/6] Creating GitHub release..."
printf "Enter release notes (or press enter for default): "
read -r notes
if [[ -z "$notes" ]]; then
  notes="Release v$VERSION"
fi
gh release create "v$VERSION" --title "v$VERSION" --notes "$notes"

# -------------------------------------------------------------------------
# Step 5: Compute SHA256 and update both formulas
# -------------------------------------------------------------------------

echo "[5/6] Computing SHA256 and updating formulas..."
TARBALL_URL="https://github.com/$GITHUB_REPO/archive/refs/tags/v$VERSION.tar.gz"
SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')
echo "  SHA256: $SHA256"

# Update formula in main repo
sed -i '' "s/sha256 \"PLACEHOLDER\"/sha256 \"$SHA256\"/" homebrew/ghh.rb
git add homebrew/ghh.rb
git commit -m "fix: add release SHA256 to Homebrew formula"
git push

# Update formula in tap repo
echo "[6/6] Updating Homebrew tap..."
cd "$TAP_DIR"
git pull --rebase
sed -i '' "s|archive/refs/tags/v.*\.tar\.gz|archive/refs/tags/v$VERSION.tar.gz|" Formula/ghh.rb
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/ghh.rb
git add Formula/ghh.rb
git commit -m "chore: bump ghh to v$VERSION"
git push

# -------------------------------------------------------------------------
# Done
# -------------------------------------------------------------------------

echo ""
echo "  Released v$VERSION"
echo "  https://github.com/$GITHUB_REPO/releases/tag/v$VERSION"
echo ""
