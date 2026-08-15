{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "herdr-tab-rename";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  cargoLock.lockFile = ./Cargo.lock;

  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/rhencloud.tab-rename
    cp ${./herdr-plugin.toml} $out/share/rhencloud.tab-rename/herdr-plugin.toml
  '';

  meta = {
    description = "Herdr plugin for auto-renaming tabs based on foreground directory";
    homepage = "https://herdr.dev";
    license = lib.licenses.mit;
    mainProgram = "herdr-tab-rename";
    platforms = lib.platforms.linux;
  };
}
