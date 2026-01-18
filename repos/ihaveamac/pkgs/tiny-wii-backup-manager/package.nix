{
  lib,
  stdenv,
  rustPlatform,
  makeDesktopItem,
  fetchFromGitHub,
}:

let
  name = "tiny-wii-backup-manager";
  # based on https://github.com/mq1/TinyWiiBackupManager/blob/main/scripts/bundle.py
  # maybe this should read it from Cargo.toml, like the script does
  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    desktopName = "TinyWiiBackupManager";
    comment = "A dead simple Wii Backup Manager";
    categories = [ "Utility" ];
  };
in
rustPlatform.buildRustPackage rec {
  pname = "TinyWiiBackupManager";
  version = "4.9.19";

  src = fetchFromGitHub {
    owner = "mq1";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-g6W7fCh/LxoHMs4DVa9BD163k3XgI4G31CsGSP3Eknc=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-TJsim+VcGtkt0LWHFvzTmH9a5z2l8o6funs8bUvwrRU=";

  postInstall =
    if stdenv.isDarwin then
      ''
        # ???
      ''
    else
      ''
        ???
        #mkdir -p $out/share/applications
        #cp ${desktopItem}/share/applications/*.desktop $out/share/applications
        #mkdir -p $out/share/icons/hicolor
        #cp -r ${src}/assets/linux/* $out/share/icons/hicolor
      '';

  meta = with lib; {
    description = "A tiny game backup and homebrew app manager for the Wii ";
    homepage = "https://github.com/mq1/TinyWiiBackupManager";
    license = licenses.gpl3;
    platforms = platforms.all;
    #mainProgram = name;
  };
}
