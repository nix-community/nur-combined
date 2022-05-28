{ stdenv, pkgs, makeDesktopItem }:

let
  desktopItem = makeDesktopItem {
    categories = [
      "GTK"
      "Network"
      "WebBrowser"
    ];
    desktopName = "Relay Browser";
    exec = "rbrowser %U";
    genericName = "Web Browser";
    icon = "chromium";
    mimeTypes = [
      "application/xhtml+xml"
      "text/html"
      "text/mml"
      "text/xml"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    name = "rbrowser";
  };

in
stdenv.mkDerivation rec {
  name = "rbrowser";

  phases = [ "installPhase" "fixupPhase" ];

  preferLocalBuild = true;

  src = ./.;

  installPhase = ''
    install -D -m755 $src/bin/rbrowser $out/bin/rbrowser
    substituteInPlace $out/bin/rbrowser \
      --subst-var-by chromium_bin ${pkgs.chromium}/bin/chromium \
      --subst-var-by firefox_bin ${pkgs.firefox}/bin/firefox \
      --subst-var-by brave_bin ${pkgs.brave}/bin/brave \
      --subst-var-by rofi_bin ${pkgs.rofi}/bin/rofi \
      --subst-var-by zsh_bin ${pkgs.zsh}/bin/zsh

    install -dm755 $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
  '';
}
