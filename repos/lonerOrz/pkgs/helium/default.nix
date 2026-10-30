{
  lib,
  pkgs,
  ...
}:
let
  version = "0.20.3.1";
  sourceMap = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-H69Thkj+FKHqkuMlyxI4rojEeGZsteY9DSrxcP5MoDc=";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64.AppImage";
      hash = "sha256-K/GER5WGM6GPUF80P9LyzM1cD3VzMFN3eGVaa6/KEQA=";
    };
  };
in
pkgs.appimageTools.wrapType2 (finalAttrs: {
  pname = "helium";
  inherit version;

  src = sourceMap.${pkgs.stdenv.hostPlatform.system};

  extraInstallCommands = ''
    mkdir -p $out/share/{applications,lib/helium}

    cp -r ${finalAttrs.contents}/opt/${finalAttrs.pname}/locales "$out/share/lib/helium"
    cp -r ${finalAttrs.contents}/usr/share/* "$out/share"

    cp "${finalAttrs.contents}/${finalAttrs.pname}.desktop" "$out/share/applications/"
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
})
