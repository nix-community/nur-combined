{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "hayase";
  version = "6.4.34";

  src = pkgs.fetchurl {
    url = "https://github.com/hayase-app/ui/releases/download/v${version}/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-P5xTTcw2fgnv/eGG4bpFKywu4w2Cl7Bj1/BA8nKnMDA=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  extraInstallCommands = let
    contents = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/hayase"
    cp -r ${contents}/{locales,resources} "$out/share/lib/hayase"
    cp -r ${contents}/usr/share/* "$out/share"
    cp "${contents}/${pname}.desktop" "$out/share/applications/"
    wrapProgram $out/bin/hayase --add-flags "--ozone-platform=wayland"
    substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

  meta = {
    description = "Hayase - Torrent streaming made simple";
    homepage = "https://hayase.watch";
    changelog = "https://hayase.watch/changelog";
    license = lib.licenses.bsl11;
    mainProgram = "hayase";
    broken = true;
  };
}
