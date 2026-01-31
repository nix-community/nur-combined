{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "hayase";
  version = "6.4.52";

  src = pkgs.fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-7Xar1NNWL2uLuhrsNyB6dTx8y0XDecotbs09WKzkWag=";
  };

  passthru.updateScript =
    pkgs.writeScript "update-${pname}"
    # bash
    ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl yq-go common-updater-scripts

      set -eu -o pipefail

      version="$(curl -s https://api.hayase.watch/files/latest-linux.yml | yq '.version')"
      update-source-version ${pname} "$version"
    '';

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
  };
}
