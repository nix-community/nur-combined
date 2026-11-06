{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  tree,
  imagemagick,
  callPackage,
  webkitgtk_4_1,
  libsoup_3,
  gtk3,
  glib-networking,
  gst_all_1,
  noto-fonts-cjk-sans,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "hongguo-desktop";
  version = current.version;

  versionFile = "pkgs/hongguo-desktop/version.json";

  architectures.x86_64-linux = "x86_64";

  system = stdenv.hostPlatform.system;

  releaseBase = "https://github.com/aston314/hongguo-tv-releases/releases/download";

  urlFor =
    version: system:
    let
      arch = architectures.${system} or (throw "hongguo-desktop: unsupported system: ${system}");
    in
    "${releaseBase}/linux-v${version}-test.1/hongguo-desktop-${version}-${arch}.AppImage";

  hashUrls = lib.mapAttrs (system: _: urlFor "@VERSION@" system) architectures;

  templateCommands = {
    VERSION = ''
      set -euo pipefail

      AUTH_HEADER=()
      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        AUTH_HEADER=(-H "Authorization: Bearer $GITHUB_TOKEN")
      fi

      curl -fsSL "''${AUTH_HEADER[@]}" \
        "https://api.github.com/repos/aston314/hongguo-tv-releases/releases?per_page=100" \
        | jq -er '
            [.[] | select(.assets[]?.name | endswith(".AppImage"))]
            | first
            | .tag_name
            | sub("^linux-v"; "")
            | sub("-test.*$"; "")
          '
    '';
  };

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

  src = sourceMap.${system} or (throw "hongguo-desktop: unsupported system: ${system}");

  nativeBuildInputs = [
    tree
    makeWrapper
    imagemagick
  ];

  # Dependencies are injected via callPackage from the function arguments
  # above; the callback argument is intentionally ignored.
  extraPkgs = _: [
    webkitgtk_4_1
    libsoup_3
    gtk3
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-ugly
    noto-fonts-cjk-sans # chinese
  ];

  extraInstallCommands = ''
    tree ${finalAttrs.contents}
    cat ${finalAttrs.contents}/README.md

    # Upstream ships hongguo-tv.desktop and hongguo-tv.png at the AppImage root.
    install -m 444 -D \
      ${finalAttrs.contents}/hongguo-tv.desktop \
      $out/share/applications/hongguo-desktop.desktop

    # Generate icons. Upstream Icon= and StartupWMClass= both use "hongguo-tv".
    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
      ${lib.getExe' imagemagick "magick"} \
        ${finalAttrs.contents}/hongguo-tv.png \
        -background none \
        -resize "''${size}x''${size}" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/hongguo-tv.png"
    done

    substituteInPlace $out/share/applications/hongguo-desktop.desktop \
      --replace-fail 'Exec=hongguo-tv' 'Exec=hongguo-desktop'

    wrapProgram $out/bin/hongguo-desktop \
      --set GDK_BACKEND "x11" \
      --set WEBKIT_DISABLE_DMABUF_RENDERER "1" \
      --set HONGGUO_WEBKIT_GPU_POLICY "never"
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
    description = "Hongguo short drama desktop client";
    homepage = "https://github.com/aston314/hongguo-tv-releases";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames architectures;
    mainProgram = pname;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
