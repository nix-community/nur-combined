{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
}:
let
  pname = "fluxer";
  version = "0.0.8";

  sourceMap = {
    x86_64-linux = fetchurl {
      url = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage";
      hash = "sha256-GdoBK+Z/d2quEIY8INM4IQy5tzzIBBM+3CgJXQn0qAw=";
    };

    # 如果官方有提供 arm64 版本的 AppImage，更新脚本会自动替换HASH
    aarch64-linux = fetchurl {
      url = "https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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

    # Install desktop
    mkdir -p $out/share/applications
    install -Dm644 ${appimageContents}/fluxer.desktop $out/share/applications/fluxer.desktop
    substituteInPlace $out/share/applications/fluxer.desktop \
      --replace-fail Exec=AppRun Exec=fluxer

    # Copy icons
    cp -r ${appimageContents}/usr/share/icons $out/share/

    wrapProgram $out/bin/fluxer \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--enable-wayland-ime" \
      --add-flags "--disable-gpu"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Fluxer Desktop Application";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = builtins.attrNames sourceMap;
    mainProgram = pname;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
