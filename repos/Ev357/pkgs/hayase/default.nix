{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapAppImage rec {
  pname = "hayase";
  version = "6.4.86";

  src = pkgs.fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-Qdi5NO8G8JLUFNDJoCvnM/zZsDlEPn3/GnKAoAosG+0=";
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

  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  extraInstallCommands =
    # bash
    ''
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/lib/hayase"
      cp -r ${appimageContents}/{locales,resources} "$out/share/lib/hayase"
      cp -r ${appimageContents}/usr/share/* "$out/share"
      cp "${appimageContents}/${pname}.desktop" "$out/share/applications/"
      wrapProgram $out/bin/hayase --add-flags "--ozone-platform=wayland"
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

  meta = {
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    description = "Hayase - Torrent streaming made simple";
    homepage = "https://hayase.watch";
    changelog = "https://hayase.watch/changelog";
    license = lib.licenses.bsl11;
    mainProgram = "hayase";
  };
}
