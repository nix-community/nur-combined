#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq yq-go nix-prefetch-github ripgrep common-updater-scripts coreutils gnused

set -euo pipefail

cd "$(dirname "$0")"

OWNER="edde746"
REPO="plezy"

# Get latest release tag (removing 'v' prefix if present for version field, keeping for tag)
LATEST_TAG=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r '.tag_name')
VERSION=${LATEST_TAG#v}

CURRENT_VERSION=$(grep -oP 'version = "\K[^"]+' default.nix)

if [ "$VERSION" = "$CURRENT_VERSION" ]; then
    echo "plezy is already up to date (version $VERSION)"
    exit 0
fi

echo "Updating plezy from $CURRENT_VERSION to $VERSION"

# 1. Prefetch source
echo "Prefetching source..."
HASH=$(nix-prefetch-url --unpack "https://github.com/$OWNER/$REPO/archive/refs/tags/$LATEST_TAG.tar.gz")
SRI_HASH=$(nix hash to-sri --type sha256 "$HASH")

# 2. Update default.nix version and hash
sed -i "s/version = \".*\";/version = \"$VERSION\";/" default.nix
# Use perl to replace hash only inside src = fetchFromGitHub block
perl -i -0777 -pe "s/(src = fetchFromGitHub \{[^}]*hash = \")sha256-[^\"]+(\";)/\$1$SRI_HASH\$2/s" default.nix

# 3. Update pubspec.lock.json
echo "Updating pubspec.lock.json..."
curl -sL "https://raw.githubusercontent.com/$OWNER/$REPO/$LATEST_TAG/pubspec.lock" -o pubspec.lock
yq -o=json pubspec.lock > pubspec.lock.json
rm pubspec.lock

# 4. Update os_media_controls hash
echo "Updating os_media_controls..."
OS_MEDIA_CONTROLS_REF=$(jq -r '.packages.os_media_controls.description."resolved-ref"' pubspec.lock.json)
echo "os_media_controls ref: $OS_MEDIA_CONTROLS_REF"
OS_MEDIA_CONTROLS_HASH=$(nix-prefetch-url --unpack "https://github.com/edde746/os-media-controls/archive/$OS_MEDIA_CONTROLS_REF.tar.gz")
OS_MEDIA_CONTROLS_SRI=$(nix hash to-sri --type sha256 "$OS_MEDIA_CONTROLS_HASH")

# Perl regex to replace os_media_controls hash specifically
perl -i -pe "s|os_media_controls = \"sha256-.*\"|os_media_controls = \"$OS_MEDIA_CONTROLS_SRI\"|" default.nix

# 5. Update flutter_webrtc / libwebrtc
echo "Updating flutter_webrtc..."
FLUTTER_WEBRTC_VERSION=$(jq -r '.packages.flutter_webrtc.version' pubspec.lock.json)
echo "flutter_webrtc version: $FLUTTER_WEBRTC_VERSION"

# Check if URL in default.nix needs update
CURRENT_WEBRTC_URL=$(grep -oP 'url = "\K[^"]+' default.nix | grep "libwebrtc.zip")

NEW_WEBRTC_URL="https://github.com/flutter-webrtc/flutter-webrtc/releases/download/v${FLUTTER_WEBRTC_VERSION}/libwebrtc.zip"

if [ "$CURRENT_WEBRTC_URL" != "$NEW_WEBRTC_URL" ]; then
    echo "Updating libwebrtc URL to $NEW_WEBRTC_URL"
    sed -i "s|$CURRENT_WEBRTC_URL|$NEW_WEBRTC_URL|" default.nix
    
    echo "Prefetching libwebrtc..."
    WEBRTC_HASH=$(nix-prefetch-url --unpack "$NEW_WEBRTC_URL")
    WEBRTC_SRI=$(nix hash to-sri --type sha256 "$WEBRTC_HASH")
    
    # We assume the libwebrtc hash is the first hash in the file or distinctly close to the URL.
    # To be safe, let's target the hash inside the libwebrtc fetchzip block.
    # We can use perl with multi-line match or just manual context.
    # Given the file structure, the first fetchzip is libwebrtc.
    
    # Use perl to replace the hash associated with libwebrtc
    # Reading file into variable
    perl -0777 -i -pe "s|(url = \"$NEW_WEBRTC_URL\";\s+hash = \")sha256-[^\"]+(\";)|L1$WEBRTC_SRI\2|s" default.nix
else
    echo "libwebrtc URL unchanged."
fi

echo "Update complete!"

# Optionally commit changes
if command -v git &> /dev/null && [ -d "../../.git" ]; then
    git add default.nix pubspec.lock.json
    git commit -m "plezy: $CURRENT_VERSION -> $VERSION" || true
fi
