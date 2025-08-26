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
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "mq1";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-MoPGGp5Zx92ybE518KPLfzaBPBXjZDwmbCRjrOU5JUA=";
  };

  cargoHash = "sha256-2x0QrxbnoMM+5Nnia+p0O0afGENHm68kekNSpMICyAI=";

  postInstall =
    if stdenv.isDarwin then
      ''
        appContents=$out/Applications/TinyWiiBackupManager.app/Contents
        mkdir -p $appContents/MacOS $appContents/Resources
        ln -s $out/bin/${name} $appContents/MacOS/
        cp ${./Info.plist} $appContents/Info.plist
        cp ${src}/assets/macos/${name}.icns $appContents/Resources
        substituteInPlace $appContents/Info.plist --replace-fail VERSION ${version}
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
  };
}
