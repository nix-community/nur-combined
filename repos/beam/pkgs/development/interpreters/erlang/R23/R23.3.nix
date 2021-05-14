{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/erlang/otp/archive/OTP-${version}.tar.gz
mkDerivation {
  version = "23.3";
  sha256 = "1qg3lzrnfrmc3xiij3v75zsfk6j1387v0dz7dca1kmj3zkjxqvhp";

  prePatch = ''
    substituteInPlace make/configure.in --replace '`sw_vers -productVersion`' "''${MACOSX_DEPLOYMENT_TARGET:-10.12}"
    substituteInPlace erts/configure.in --replace '-Wl,-no_weak_imports' ""
  '';
}
