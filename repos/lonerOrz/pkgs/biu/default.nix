{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
  imagemagick,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "biu";
  version = current.version;

  versionFile = "pkgs/biu/version.json";

  # Map Nix system names to upstream asset architecture names.
  architectures = {
    x86_64-linux = "x86_64";
    aarch64-linux = "arm64";
  };

  system = stdenv.hostPlatform.system;

  # Generate the upstream GitHub Release URL.
  releaseBase = "https://github.com/wood3n/biu/releases/download";

  urlFor =
    version: system:
    let
      arch = architectures.${system} or (throw "biu: unsupported system: ${system}");
    in
    "${releaseBase}/v${version}/Biu-${version}-linux-${arch}.AppImage";

  # Generate URL templates for all supported architectures.
  hashUrls = lib.mapAttrs (system: _: urlFor "@VERSION@" system) architectures;

  # Fetch the latest upstream GitHub Release version.
  templateCommands = {
    VERSION = ''
      curl -fsSL \
        "https://api.github.com/repos/wood3n/biu/releases/latest" |
        jq -er '.tag_name | ltrimstr("v")'
    '';
  };

  # Prepare AppImage sources for every supported architecture.
  sourceMap = lib.mapAttrs (
    system: _:
    fetchurl {
      url = urlFor version system;
      hash = current.${system + "-hash"};
    }
  ) architectures;
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname version;

  src = sourceMap.${system} or (throw "biu: unsupported system: ${system}");

  nativeBuildInputs = [
    tree
    makeWrapper
    imagemagick
  ];

  extraInstallCommands = ''
    tree ${finalAttrs.contents}

    # Install the upstream desktop entry.
    install -m 444 -D \
      ${finalAttrs.contents}/Biu.desktop \
      $out/share/applications/biu.desktop

    # Generate icons for supported desktop environments.
    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"

      magick convert \
        -background none \
        -resize "''${size}x''${size}" \
        ${finalAttrs.contents}/Biu.png \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/Biu.png"
    done

    # Replace the AppImage launcher with the Nix package executable.
    substituteInPlace $out/share/applications/biu.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=biu'

    # Configure Electron for X11 and Wayland input support.
    wrapProgram $out/bin/biu \
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
    description = "Bilibili music desktop client";
    homepage = "https://github.com/wood3n/biu";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames architectures;
    mainProgram = "biu";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
