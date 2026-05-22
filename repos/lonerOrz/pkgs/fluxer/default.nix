{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;

  pname = "fluxer";
  version = current.version;

  sourceMap = {
    x86_64-linux = fetchurl {
      url = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage";
      hash = current.x86_64-linux-hash;
    };

    # 如果官方有提供 arm64 版本的 AppImage，更新脚本会自动替换HASH
    aarch64-linux = fetchurl {
      url = "https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage";
      hash = current.aarch64-linux-hash;
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

  passthru.updateScript =
    let
      versionFile = "pkgs/fluxer/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "fluxer";
      updateMethod = "none";
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/fetch-urls.nix {
          inherit versionFile;
          versionCommand = ''
            curl -sI "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage" \
              | grep -i "^content-disposition:" \
              | sed -n 's/.*fluxer-stable-\([0-9.]*\)-x86_64\.AppImage.*/\1/p'
          '';
          hashUrls = {
            x86_64-linux = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage";
            aarch64-linux = "https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage";
          };
        }
      )}";
    };

  meta = {
    description = "Fluxer Desktop Application";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = builtins.attrNames sourceMap;
    mainProgram = pname;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
