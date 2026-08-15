# Locate a real Metal compiler. XcodeDefault's metal stub cannot compile.
# Xcode 26+ mounts MetalToolchain under cryptexd; xcrun only finds it if
# ~/Library has the mapping plist, but the Nix build HOME is a temp dir.
METAL=
METALLIB=
for d in \
  /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-*/Metal.xctoolchain \
  /private/var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-*/Metal.xctoolchain \
  /Users/Shared/Metal.xctoolchain \
  /Users/*/Library/Developer/DVTDownloads/MetalToolchain/mounts/*/Metal.xctoolchain; do
  if [ -x "$d/usr/bin/metal" ] && [ -x "$d/usr/bin/metallib" ]; then
    METAL="$d/usr/bin/metal"
    METALLIB="$d/usr/bin/metallib"
    break
  fi
done
if [ -z "$METAL" ]; then
  METAL="$(xcrun --sdk macosx --find metal 2>/dev/null || true)"
  METALLIB="$(xcrun --sdk macosx --find metallib 2>/dev/null || true)"
  case "$METAL" in *XcodeDefault.xctoolchain*) METAL= ;; esac
  case "$METALLIB" in *XcodeDefault.xctoolchain*) METALLIB= ;; esac
fi
if [ ! -x "$METAL" ] || [ ! -x "$METALLIB" ]; then
  echo "Metal compiler not found (cryptexd mount, /Users/Shared/Metal.xctoolchain, xcrun)." >&2
  echo "On the host run: xcodebuild -downloadComponent MetalToolchain && xcrun --find metal" >&2
  exit 1
fi
echo "Using METAL=$METAL"
echo "Using METALLIB=$METALLIB"
