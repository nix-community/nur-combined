# shellcheck shell=bash

# Setup shim for macOS builds that drive the host's Xcode (Flutter's macOS
# target, xcrun-based Swift builds). The Nix sandbox does not expose
# /Applications, so the packages using this set `__noChroot = true`; what they
# still need is for the host tools to behave inside the Nix build directory:
#
#  * xcodebuild only runs from inside a complete Xcode.app, and it copies build
#    products with rsync into directories that are read-only after the first
#    build. Put a FakeXcode.app of symlinks to the real developer directory on
#    the path, with an xcodebuild wrapper that pins ARCHS to the host
#    architecture, disables the package/plugin sandboxes (they need a writable
#    HOME) and an rsync wrapper that makes the destination writable again.
#  * CoreFoundation bypasses $HOME, so point CFFIXED_USER_HOME at it
#    explicitly; otherwise the toolchain gets a user.home it cannot write.
#
# Usage, from `preBuild`, after making the source's macos/ directory writable:
#
#   source ${../../../shared/darwin-xcode-shim.sh}
#   fakeXcodeSetup
#
# It exports DEVELOPER_DIR, PATH and CFFIXED_USER_HOME into the calling shell.
# REAL_DEV_DIR is honoured when already set (e.g. to a non-default Xcode).

fakeXcodeSetup() {
    REAL_DEV_DIR="${REAL_DEV_DIR:-/Applications/Xcode.app/Contents/Developer}"
    export REAL_DEV_DIR
    export FAKE_XCODE="$PWD/FakeXcode.app"
    export FAKE_DEV_DIR="$FAKE_XCODE/Contents/Developer"

    real_xcode=$(dirname "$REAL_DEV_DIR")

    # xcrun only treats the bundle as an Xcode install when the plists are there.
    mkdir -p "$FAKE_DEV_DIR/usr/bin"
    ln -sf "$real_xcode/Info.plist" "$FAKE_XCODE/Contents/"
    ln -sf "$real_xcode/version.plist" "$FAKE_XCODE/Contents/"

    # Mirror the developer directory (Platforms, Toolchains, Library, ...), but
    # not usr: its bin/ is rebuilt so xcodebuild can be wrapped.
    for entry in "$REAL_DEV_DIR"/*; do
        if [ "$(basename "$entry")" != usr ]; then
            ln -sf "$entry" "$FAKE_DEV_DIR/"
        fi
    done
    mkdir -p "$FAKE_DEV_DIR/usr"
    for entry in "$REAL_DEV_DIR"/usr/*; do
        if [ "$(basename "$entry")" != bin ]; then
            ln -sf "$entry" "$FAKE_DEV_DIR/usr/"
        fi
    done
    for entry in "$REAL_DEV_DIR"/usr/bin/*; do
        ln -sf "$entry" "$FAKE_DEV_DIR/usr/bin/"
    done

    # Replace the symlink mirrored above, not its target in the real Xcode
    # bundle (which is SIP-protected), with the wrapper.
    rm -f "$FAKE_DEV_DIR/usr/bin/xcodebuild"
    cat > "$FAKE_DEV_DIR/usr/bin/xcodebuild" <<'EOF'
#!/bin/sh
exec "$REAL_DEV_DIR/usr/bin/xcodebuild" \
    ARCHS="$(uname -m)" \
    ONLY_ACTIVE_ARCH=YES \
    -IDEPackageSupportDisableManifestSandbox=YES \
    -IDEPackageSupportDisablePluginExecutionSandbox=YES \
    "$@"
EOF
    chmod +x "$FAKE_DEV_DIR/usr/bin/xcodebuild"

    # xcodebuild's copy phases run rsync; the previous build's products are
    # read-only in the Nix build directory, which makes the copy fail.
    mkdir -p "$PWD/custom_bin"
    cat > "$PWD/custom_bin/rsync" <<'EOF'
#!/bin/sh
/usr/bin/rsync "$@"
status=$?
if [ "$status" -eq 0 ]; then
    for arg in "$@"; do
        destination=$arg
    done
    if [ -n "${destination-}" ] && [ -d "$destination" ]; then
        chmod -R u+w "$destination" || true
    fi
fi
exit "$status"
EOF
    chmod +x "$PWD/custom_bin/rsync"

    export DEVELOPER_DIR="$FAKE_DEV_DIR"
    # Put the host toolchain ahead of Nix's: the SDK and the compilers Dart and
    # Flutter ask for only exist in Xcode, and nixpkgs' stub xcrun would
    # otherwise answer the SDK lookups with "unable to find sdk".
    export PATH="$PWD/custom_bin:$FAKE_DEV_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    export CFFIXED_USER_HOME="$HOME"
}
