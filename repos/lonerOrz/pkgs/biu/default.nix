{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
}:
let
  pname = "biu";
  version = "1.16.0";

  sourceMap = {
    x86_64-linux = fetchurl {
      url = "https://github.com/wood3n/biu/releases/download/v${version}/Biu-${version}-linux-x86_64.AppImage";
      hash = "sha256-GNO2jgq3igBsiu3+d/5PGO73LwDcDU6M1aIN9Qlj7jI=";
    };

    aarch64-linux = fetchurl {
      url = "https://github.com/wood3n/biu/releases/download/v${version}/Biu-${version}-linux-arm64.AppImage";
      hash = "sha256-QTGKFS/huNgSDyT9QlBCmfETkcYPjZDXsBe5m7TcCmY=";
    };
  };

  src = sourceMap.${stdenv.hostPlatform.system};

  appimageContents = appimageTools.extractType2 {
    inherit src pname version;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [
    tree
    makeWrapper
  ];

  extraInstallCommands = ''
    tree ${appimageContents}

    install -m 444 -D \
      ${appimageContents}/Biu.desktop \
      $out/share/applications/biu.desktop

    cp -r \
      ${appimageContents}/usr/share/icons/hicolor \
      $out/share/icons/

    substituteInPlace $out/share/applications/biu.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=biu'

    wrapProgram $out/bin/biu \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--enable-wayland-ime" \
      --add-flags "--disable-gpu"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Bilibili music desktop client";
    homepage = "https://github.com/wood3n/biu";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames sourceMap;
    mainProgram = "biu";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
