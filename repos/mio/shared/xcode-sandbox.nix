# Helpers for the packages that build against the host's Xcode instead of
# stdenv's Apple SDK.
#
# The xcodebuild packages keep the sandbox and admit what Xcode's tools read and
# the mach services they talk to (`base` / `withMetalToolchain`); the deny rule
# keeps Homebrew's /usr/local out of reach. The Flutter packages driving
# shared/darwin-xcode-shim.sh turn the sandbox off instead.
#
#   let
#     xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
#   in
#   stdenvNoCC.mkDerivation {
#     sandboxProfile = xcodeSandbox.base;
#     buildPhase = ''
#       runHook preBuild
#       ${xcodeSandbox.envWithPath}
#       xcodebuild ...
#     '';
#   }
#
# Pick `withMetalToolchain` when the build compiles Metal or an Icon Composer
# icon: Xcode mounts that separately downloaded toolchain through a service
# under /var/run and an asset under /System/Library/AssetsV2.
let
  base = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
  '';

  metalToolchain = ''
    (allow file-read* process-exec (subpath "/var/run/com.apple.security.cryptexd"))
    (allow file-read* process-exec (subpath "/private/var/run/com.apple.security.cryptexd"))
    (allow file-read* (subpath "/System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain"))
  '';

  # Select the host developer directory, give Foundation a home it can write to
  # (it resolves the home directory from the account database, which points at
  # /var/empty in a build), and drop stdenv's SDK and toolchain variables so the
  # host clang/swift does not inherit the Nix compiler, its SDK or its -I/-L
  # flags.
  env = ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export CFFIXED_USER_HOME=$HOME
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX
  '';

  # `env` plus a PATH that reaches Xcode's tools ahead of stdenv's stubs (xcrun,
  # actool, codesign), for the phases that call those tools by name.
  envWithPath = env + ''
    export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
  '';

  # Xcode attaches the separately downloaded Metal toolchain as a disk image
  # inside $HOME, and some builds mount it somewhere of their own. Left
  # attached, a mount keeps Nix from deleting the build directory, so detach on
  # exit, also on failure:
  #
  #   ${detachMetalToolchain}
  #   trap detach_metal_toolchain EXIT
  #
  # Pass extra mountpoints as arguments, e.g.
  # `trap 'detach_metal_toolchain "$metal_mount"' EXIT`.
  detachMetalToolchain = ''
    detach_metal_toolchain() {
      for mountpoint in "$@" "$HOME"/Library/Developer/DVTDownloads/MetalToolchain/mounts/*; do
        [ -d "$mountpoint" ] || continue
        /usr/bin/hdiutil detach -quiet "$mountpoint" || true
      done
    }
  '';
in
{
  inherit
    base
    detachMetalToolchain
    env
    envWithPath
    ;
  withMetalToolchain = base + metalToolchain;
}
