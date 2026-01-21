{
  lib,
  pkgs,
  ...
}:
let
  version = "0.8.3.1";
  sourceMap = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-GGltZ0/6rGQJixlGz3Na/vAwOlTeUR87WGyAPpLmtKM=";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64.AppImage";
      hash = "sha256-K/GER5WGM6GPUF80P9LyzM1cD3VzMFN3eGVaa6/KEQA=";
    };
  };
in
pkgs.appimageTools.wrapType2 rec {
  pname = "helium";
  inherit version;

  src = sourceMap.${pkgs.stdenv.hostPlatform.system};

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p $out/share/{applications,lib/helium}

      cp -r ${contents}/opt/${pname}/locales "$out/share/lib/helium"
      cp -r ${contents}/usr/share/* "$out/share"

      cp "${contents}/${pname}.desktop" "$out/share/applications/"
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace-fail 'Exec=AppRun' "Exec=${meta.mainProgram}"
    '';

  meta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "helium";
  };
}
