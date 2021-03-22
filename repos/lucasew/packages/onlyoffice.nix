# Broken: missing sqlite symbol in a gnome library, wtf man

{lib, fetchurl, appimageTools}:
let
  pname = "OnlyOffice";
  version = "6.0.1";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/ONLYOFFICE/appimage-desktopeditors/releases/download/v6.0.1/DesktopEditors-x86_64.AppImage";
    sha256 = "0a0a6q6g6x419kx9w7k9plqv0qlzsgjjmbbxxakz66kqn2xkz645";
    name = "${pname}.AppImage";
  };
in appimageTools.wrapType2 {
  inherit name src;
  extraPkgs = pkgs: (with pkgs; [
    pulseaudio
    sqlite.dev
    gnome3.tracker
  ]);
}
