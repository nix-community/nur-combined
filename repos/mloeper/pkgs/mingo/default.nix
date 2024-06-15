{ lib, stdenv, pkgs, fetchurl, appimageTools, ... }:

let
  pname-base = "mingo";
  version = "1.13.5";
  appImage = appimageTools.wrapType2 {
    inherit version;
    pname = "${pname-base}-wrapped";

    src = fetchurl {
      url = "https://github.com/mingo-app/mingo/releases/download/v${version}/Mingo-${version}.AppImage";
      hash = "sha256-mrFcKX7nGv4sdI3ruWk6pV9qdwZMIgbCGXHiSgFwjh8=";
    };

    extraPkgs = pkgs: with pkgs; [
      libsecret
    ];
  };
  desktopFile = pkgs.substituteAll {
    inherit version;
    src = ./share/applications/mingo.desktop;
    exec = "${appImage}/bin/${appImage.pname}";
    icon = ./share/icons/icon.png;
  };
  xdgDirectory = stdenv.mkDerivation {
    inherit version;
    pname = "${pname-base}-xdg";
    src = desktopFile;

    installPhase = ''
      install -d $out/share/applications

      cp $src $out/share/applications
    '';
    unpackPhase = ":";
  };
  appImageWrapper = (pkgs.writeShellScriptBin "mingo" "exec -a $0 ${appImage}/bin/${appImage.pname} $@"); # renames the mingo-xxxx executable to "mingo"
in
pkgs.symlinkJoin
{
  name = "${pname-base}-${version}";
  inherit version;
  paths = [ appImageWrapper xdgDirectory ];

  meta = with lib; {
    homepage = "https://mingo.io/";
    description = "The best MongoDB GUI Admin. Intuitive • Fast • Secure";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mingo";
  };
}
