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
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "mq1";
    repo = pname;
    rev = version;
    sha256 = "sha256-Y+roYFiT/xIb2nf6GgkpsHclxzv8NCUpuITL3UVLsuQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-E0PPg9/8XT+D/OF18EzUKUekVyakdPeKfDfrIewYDLk=";

  postInstall =
    if stdenv.isDarwin then
      ''
        # ???
      ''
    else
      ''
        mkdir -p $out/share/applications
        cp ${desktopItem}/share/applications/*.desktop $out/share/applications
        mkdir -p $out/share/icons/hicolor
        cp -r ${src}/assets/linux/* $out/share/icons/hicolor
      '';

  meta = with lib; {
    description = "Tool for decrypting all mogg files used by the Rock Band series";
    homepage = "https://github.com/mq1/TinyWiiBackupManager";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    mainProgram = name;
    broken = stdenv.isDarwin;
  };
}
