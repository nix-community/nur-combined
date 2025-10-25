{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "shiru";
  version = "6.2.1";

  src = pkgs.fetchurl {
    url = "https://github.com/RockinChaos/Shiru/releases/download/v${version}/linux-Shiru-v${version}.AppImage";
    hash = "sha256-4LZyLfRVhaWVeFQiip9ste5zhelzt3xut5u6rT76Pbw=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  extraInstallCommands = let
    contents = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/shiru"
    cp -r ${contents}/{locales,resources} "$out/share/lib/shiru"
    cp -r ${contents}/usr/share/* "$out/share"
    cp "${contents}/${pname}.desktop" "$out/share/applications/"
    wrapProgram $out/bin/shiru --add-flags "--ozone-platform=wayland"
    substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

  meta = {
    description = "BitTorrent streaming software with no paws in the way—watch anime in real-time, no waiting for downloads!";
    homepage = "https://github.com/RockinChaos/Shiru";
    changelog = "https://github.com/RockinChaos/Shiru/releases/tag/v${version}";
    license = lib.licenses.gpl3;
    mainProgram = "shiru";
  };
}
