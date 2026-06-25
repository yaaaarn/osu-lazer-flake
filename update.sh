#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-scripts curl gnused jq

set -euo pipefail

info() { echo "[*] $*"; }

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_FILE="$PKG_DIR/package.nix"

# get latest version from ppy/osu releases
info "fetching latest osu!lazer version..."
LATEST=$(curl -sSfL "https://api.github.com/repos/ppy/osu/releases?per_page=1" | jq -r '.[0].tag_name' | sed 's/-lazer//')
info "latest: $LATEST"

# read current version from package.nix
CURRENT=$(sed -n 's/^\s*version = "\(.*\)";/\1/p' "$PKG_FILE")
info "current: $CURRENT"

if [ "$LATEST" = "$CURRENT" ]; then
  info "already up to date"
  exit 0
fi

# assets to update: name -> url template -> hash var name (for sed)
declare -A ASSETS
ASSETS["aarch64-darwin"]="https://github.com/ppy/osu/releases/download/${LATEST}-lazer/osu.app.Apple.Silicon.zip"
ASSETS["x86_64-darwin"]="https://github.com/ppy/osu/releases/download/${LATEST}-lazer/osu.app.Intel.zip"
ASSETS["x86_64-linux"]="https://github.com/ppy/osu/releases/download/${LATEST}-lazer/osu.AppImage"

update_version() {
  info "updating version to $LATEST"
  sed -i "s/version = \".*\";/version = \"$LATEST\";/" "$PKG_FILE"
}

update_badge() {
  info "updating readme badge to $LATEST"
  sed -i "s/version-[0-9.]*-blue/version-$LATEST-blue/" "$PKG_DIR/README.md"
}

update_hash() {
  local key="$1"
  local url="$2"
  local unpack_flag="$3"

  info "computing hash for $key ($url)"

  # compute SRI hash
  if [ "$unpack_flag" = "true" ]; then
    HASH=$(nix-prefetch-url --type sha256 --unpack "$url" 2>/dev/null)
  else
    HASH=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
  fi

  SRI=$(nix-hash --type sha256 --to-sri $HASH 2>/dev/null)
  
  # escape forward slashes in SRI for sed
  SRI_ESC=$(echo "$SRI" | sed 's|/|\\/|g')

  sed -i "/$key/,/hash/ s/hash = \".*\";/hash = \"$SRI\";/" "$PKG_FILE"
}

update_version

update_badge

update_hash "aarch64-darwin" "${ASSETS[aarch64-darwin]}" "true"
update_hash "x86_64-darwin" "${ASSETS[x86_64-darwin]}" "true"
update_hash "x86_64-linux" "${ASSETS[x86_64-linux]}" "false"

info "done! updated to $LATEST"
