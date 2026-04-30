#!/usr/bin/env bash
set -euo pipefail

OWNER="mroboff"
REPO="vm-curator"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
CARGO_LOCK="$SCRIPT_DIR/Cargo.lock"

# --- Resolve target version ---

if [[ $# -eq 0 ]]; then
    echo "Fetching latest release from GitHub..."
    RELEASE_JSON=$(curl -sf "https://api.github.com/repos/$OWNER/$REPO/releases/latest")
    VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
    REV=$(echo "$RELEASE_JSON" | grep '"target_commitish"' | sed 's/.*"target_commitish": *"\(.*\)".*/\1/')
    # Prefer the tag itself as rev for reproducibility
    REV="$VERSION"
    echo "Latest release: $VERSION (rev: $REV)"
else
    VERSION="$1"
    REV="$1"
    echo "Target: $VERSION"
fi

# Strip leading 'v' for the version field in default.nix
VERSION_CLEAN="${VERSION#v}"

# --- Current values ---
CURRENT_REV=$(grep 'rev =' "$DEFAULT_NIX" | sed 's/.*rev = "\(.*\)".*/\1/')
if [[ "$CURRENT_REV" == "$REV" ]]; then
    echo "Already at $REV, nothing to do."
    exit 0
fi

# --- Fetch new src hash ---
echo "Fetching source hash..."
RAW_HASH=$(nix-prefetch-url --unpack \
    "https://github.com/$OWNER/$REPO/archive/$REV.tar.gz" 2>/dev/null)
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$RAW_HASH")
echo "Hash: $SRI_HASH"

# --- Update Cargo.lock ---
echo "Downloading Cargo.lock..."
curl -sf "https://raw.githubusercontent.com/$OWNER/$REPO/$REV/Cargo.lock" \
    -o "$CARGO_LOCK"

# --- Update default.nix ---
echo "Updating default.nix..."
sed -i \
    -e "s|version = \".*\";|version = \"$VERSION_CLEAN\";|" \
    -e "s|rev = \".*\";|rev = \"$REV\";|" \
    -e "s|hash = \".*\";|hash = \"$SRI_HASH\";|" \
    "$DEFAULT_NIX"

echo ""
echo "Updated to $VERSION_CLEAN. Testing build..."
echo "(This compiles from scratch and may take a while)"
echo ""

if nix build --impure --expr \
    "(import <nixpkgs> {}).callPackage $DEFAULT_NIX {}" 2>&1; then
    echo ""
    echo "Build successful. Don't forget to check if the patch still applies cleanly:"
    echo "  git -C $SCRIPT_DIR diff"
    echo ""
    echo "Then stage and commit:"
    echo "  git -C $(dirname "$SCRIPT_DIR") add packages/vm-curator/"
else
    echo ""
    echo "Build failed. Likely the patch needs updating for the new version."
    echo "Check the output above for 'Hunk FAILED' messages."
    exit 1
fi
