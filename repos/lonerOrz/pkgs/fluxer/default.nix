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

    aarch64-linux = fetchurl {
      url = "https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage";
      hash = current.aarch64-linux-hash;
    };
  };

  src = sourceMap.${stdenv.hostPlatform.system};

  appimageContents = appimageTools.extract {
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
    # Install desktop entry from the stable AppImage
    install -Dm644 \
      ${appimageContents}/fluxer.desktop \
      $out/share/applications/fluxer.desktop

    # The stable AppImage ships fluxer.png, not fluxer-canary.png
    install -Dm644 \
      ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/fluxer.png \
      $out/share/icons/hicolor/1024x1024/apps/fluxer.png

    # Make the desktop entry usable after AppImage extraction.
    # Do not use --replace-fail here: the upstream stable desktop
    # entry may already contain the desired values.
    sed -i \
      -e 's|^Exec=.*$|Exec=fluxer %U|' \
      -e 's|^Icon=.*$|Icon=fluxer|' \
      -e 's|^StartupWMClass=.*$|StartupWMClass=fluxer|' \
      $out/share/applications/fluxer.desktop

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
            curl -sIL "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage" \
              | grep -i "^x-fluxer-version:" \
              | awk '{print $2}' \
              | tr -d '\r'
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
