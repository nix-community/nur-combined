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

  versionFile = "pkgs/fluxer/version.json";

  # Upstream download endpoints for each supported architecture.
  urls = {
    x86_64-linux = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage";
    aarch64-linux = "https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage";
  };

  # Use the x86_64 endpoint to retrieve the shared desktop version.
  templateCommands = {
    VERSION = ''
      curl -fsSIL "${builtins.getAttr "x86_64-linux" urls}" |
        awk '
          tolower($1) == "x-fluxer-version:" {
            gsub(/\r/, "", $2)
            version = $2
          }
          END {
            if (version == "") {
              print "Failed to find X-Fluxer-Version header" > "/dev/stderr"
              exit 1
            }
            print version
          }
        '
    '';
  };

  # Reuse the same download endpoints for hash calculation.
  hashUrls = urls;

  # Fetch sources for each supported architecture.
  sourceMap = lib.mapAttrs (
    system: url:
    fetchurl {
      inherit url;
      hash = current.${system + "-hash"};
    }
  ) urls;

  system = stdenv.hostPlatform.system;
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname version;

  src = sourceMap.${system} or (throw "fluxer: unsupported system: ${system}");

  nativeBuildInputs = [
    tree
    makeWrapper
  ];

  extraInstallCommands = ''
    # Locate and install the upstream desktop file.
    desktopFile=$(find ${finalAttrs.contents} -maxdepth 2 -name '*.desktop' | head -n1)

    install -Dm644 \
      "$desktopFile" \
      $out/share/applications/fluxer.desktop

    # Locate and install the Fluxer application icon.
    iconFile=$(find ${finalAttrs.contents} -name 'fluxer.png' | head -n1)

    install -Dm644 \
      "$iconFile" \
      $out/share/icons/hicolor/1024x1024/apps/fluxer.png

    # Normalize desktop entry fields for the Nix package.
    sed -i \
      -e 's|^Exec=.*$|Exec=fluxer %U|' \
      -e 's|^Icon=.*$|Icon=fluxer|' \
      -e 's|^StartupWMClass=.*$|StartupWMClass=fluxer|' \
      $out/share/applications/fluxer.desktop

    # Configure the application launch environment.
    wrapProgram $out/bin/fluxer \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--enable-wayland-ime" \
      --add-flags "--disable-gpu"
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    inherit pname versionFile;

    updateMethod = "none";

    fetchMetaCommand = lib.getExe (
      callPackage ../../utils/fetch-urls.nix {
        inherit versionFile templateCommands hashUrls;
      }
    );
  };

  meta = {
    description = "Fluxer Desktop Application";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = builtins.attrNames urls;
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
