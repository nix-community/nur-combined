{ lib, stdenv, pkgs, fetchurl, appimageTools, ... }:

let
  pname-base = "aptakube";
  version = "1.6.10";
  appImage = appimageTools.wrapType2 {
    inherit version;
    pname = "${pname-base}-wrapped";

    src = fetchurl {
      url = "https://releases.aptakube.com/aptakube_${version}_amd64.AppImage";
      hash = "sha256-UNtNJI0/2WkZbI89j9wt13AzssKB5DhINtzT5r94TQw=";
    };

    extraPkgs = pkgs: with pkgs; [
      libsecret
    ];
  };
  desktopFile = pkgs.substituteAll {
    inherit version;
    src = ./share/applications/aptakube.desktop;
    exec = "${appImage}/bin/${appImage.pname}";
    icon = ./share/icons/aptakube.png;
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
  appImageWrapper = (pkgs.writeShellScriptBin "aptakube" "exec -a $0 ${appImage}/bin/${appImage.pname} $@");
in
pkgs.symlinkJoin
{
  name = "${pname-base}-${version}";
  inherit version;
  paths = [ appImageWrapper ];

  meta = with lib; {
    homepage = "https://aptakube.com";
    description = "Modern. Lightweight. Multi-Cluster. Kubernetes GUI";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aptakube";
  };
}
