{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/erlang/otp/archive/OTP-${version}.tar.gz
mkDerivation {
  version = "23.2";
  sha256 = "1zlh49pn43yrps656v4spy5dx9ijpbddigig85md3qniv1w1b7fd";

  prePatch = ''
    substituteInPlace make/configure.in --replace '`sw_vers -productVersion`' "''${MACOSX_DEPLOYMENT_TARGET:-10.12}"
    substituteInPlace erts/configure.in --replace '-Wl,-no_weak_imports' ""
  '';
}
