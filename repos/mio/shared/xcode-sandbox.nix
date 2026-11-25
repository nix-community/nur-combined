# Sandbox profile for the packages that build with the host's Xcode. The ones
# driving Flutter use shared/darwin-xcode-shim.sh and turn the sandbox off; these
# keep it, so the profile admits what Xcode's tools read and the mach services
# they talk to, while the deny rule keeps Homebrew's /usr/local out of reach.
#
#   let
#     xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
#   in
#   stdenvNoCC.mkDerivation {
#     sandboxProfile = xcodeSandbox.base;
#     ...
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
in
{
  inherit base;
  withMetalToolchain = base + metalToolchain;
}
