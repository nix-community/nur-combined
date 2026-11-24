{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# Rebuilds the SteamOS rootfs from Valve's casync chunk store when the launcher
# creates a disk. Upstream ships an official 1.1.4 binary; build it from source.
buildGoModule (finalAttrs: {
  pname = "desync";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "folbricht";
    repo = "desync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ORFIGjQD0S7RPgWJqDwPH2wI6Dnv4LvOZ0tMHpOtvPM=";
  };

  vendorHash = "sha256-08LGC+N0NjUAjo9b5JhKNr46CuIXMz/erw2RPRU17xo=";

  # The test suite binds loopback HTTP servers, which the Nix sandbox forbids.
  doCheck = false;

  meta = {
    description = "Content-addressed storage and casync implementation";
    homepage = "https://github.com/folbricht/desync";
    license = lib.licenses.bsd3;
    mainProgram = "desync";
    platforms = [ "aarch64-darwin" ];
  };
})
