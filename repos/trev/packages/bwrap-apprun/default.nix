{
  bubblewrap,
  buildRustPackage ? rustPlatform.buildRustPackage,
  lib,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "bwrap-apprun";
  version = "0.0.1";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./main.rs
    ];
  };
  cargoLock.lockFile = ./Cargo.lock;

  postInstall = ''
    cp "${lib.getExe bubblewrap}" "$out/bin/bwrap"
  '';

  meta = {
    mainProgram = "AppRun";
    description = "Bwrap AppRun implementation for Type 2 AppImages";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/bwrap-apprun";
  };
})
