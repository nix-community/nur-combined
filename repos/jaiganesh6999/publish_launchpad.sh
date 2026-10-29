#!/usr/bin/env bash
# publish_launchpad.sh — Build and upload seowebchecker to Launchpad PPA
# Usage: bash publish_launchpad.sh [ubuntu_series]
# Requires: devscripts, debhelper, dh-python, dput, gpg
# Run this on Linux/WSL (not Windows)

set -euo pipefail

PACKAGE="seowebchecker"
VERSION="1.0.1"
SERIES="${1:-noble}"  # noble, jammy, focal
PPA="ppa:seoaitools/seowebchecker"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="/tmp/ppa-build/${SERIES}"
PKG="${PACKAGE}_${VERSION}"
SRC_DIR="${BUILD_DIR}/${PKG}"

echo "======================================================"
echo " Building ${PACKAGE} ${VERSION} for Ubuntu ${SERIES}"
echo " PPA: ${PPA}"
echo "======================================================"

# ── Check tools ──────────────────────────────────────────
for tool in dpkg-buildpackage dput gpg; do
    if ! command -v "$tool" &>/dev/null; then
        echo "❌ Missing: $tool"
        echo "   Install: sudo apt-get install devscripts dput debhelper dh-python"
        exit 1
    fi
done

# ── Clean & recreate build dir ────────────────────────────
rm -rf "$BUILD_DIR"
mkdir -p "$SRC_DIR"

# ── Copy source ───────────────────────────────────────────
rsync -a \
  --exclude='.git' \
  --exclude='dist/' \
  --exclude='launchpad/' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  "${SCRIPT_DIR}/" "$SRC_DIR/"

# ── Copy debian/ files ────────────────────────────────────
cp -r "${SCRIPT_DIR}/launchpad/debian" "$SRC_DIR/"

# ── Update changelog for target series ───────────────────
sed -i "s/) noble; urgency/) ${SERIES}; urgency/" \
  "$SRC_DIR/debian/changelog"

# ── Create orig tarball ───────────────────────────────────
echo "→ Creating orig tarball..."
tar -czf "${BUILD_DIR}/${PKG}.orig.tar.gz" \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='launchpad' \
  --exclude='__pycache__' \
  -C "$BUILD_DIR" "$PKG"

# ── Build source package ──────────────────────────────────
echo "→ Building Debian source package..."
cd "$SRC_DIR"
export DEBFULLNAME="SEOWebChecker Team"
export DEBEMAIL="support@seowebchecker.com"
dpkg-buildpackage -S -sa --no-check-builddeps -d

echo "→ Built files:"
ls -lh "$BUILD_DIR"/*.dsc "$BUILD_DIR"/*.changes 2>/dev/null

# ── Upload to Launchpad ───────────────────────────────────
echo "→ Uploading to Launchpad PPA: ${PPA}..."
CHANGES=$(ls "$BUILD_DIR"/*.changes | head -1)
dput "$PPA" "$CHANGES"

echo ""
echo "✅ Upload complete!"
echo "📦 PPA: https://launchpad.net/~jaiganesh6999/+archive/ubuntu/seowebchecker"
echo "🔍 Build status: https://launchpad.net/~jaiganesh6999/+archive/ubuntu/seowebchecker/+builds"
echo ""
echo "Install once built:"
echo "  sudo add-apt-repository ppa:jaiganesh6999/seowebchecker"
echo "  sudo apt-get update"
echo "  sudo apt-get install seowebchecker"
