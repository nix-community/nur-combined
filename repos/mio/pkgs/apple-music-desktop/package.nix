{
  lib,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  makeDesktopItem,
  makeBinaryWrapper,
  jq,
  nix-update-script,
  writeShellApplication,
}:

buildNpmPackage rec {
  pname = "apple-music-desktop";
  version = "2.4.1-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "Alex313031";
    repo = "apple-music-desktop";
    rev = "9325ccc6180f8c83a42669b4b43e73f819555f1f";
    hash = "sha256-5rNwWtn2ZhjYJYf61cGSyLF1DIT8MMqZuLOtPqr03yg=";
  };

  sourceRoot = "${src.name}/src";

  npmDepsHash = "sha256-kyfknq/+3oSBhK8MGNzFbXaKFbAHFgh2n+gIA4JlcCs=";
  forceGitDeps = true;
  makeCacheWritable = true;
  dontNpmBuild = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_production = "true";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    install -Dm644 ${src}/Logo.png \
      $out/share/icons/hicolor/256x256/apps/apple-music-desktop.png

    makeWrapper ${lib.getExe electron} $out/bin/apple-music-desktop \
      --add-flags $out/lib/node_modules/${pname} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "apple-music-desktop";
      exec = "apple-music-desktop %U";
      icon = "apple-music-desktop";
      desktopName = "Apple Music Desktop";
      categories = [
        "Audio"
        "AudioVideo"
        "Player"
      ];
    })
  ];

  passthru.updateScript = writeShellApplication {
    name = "update-apple-music-desktop";
    runtimeInputs = [ jq ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="apple-music-desktop"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"

      # nix-update takes the base version from the newest release tag, but this
      # package tracks commits and upstream only keeps the real version in
      # package.json. Rebase onto it, keeping the commit date nix-update wrote.
      pkg_file=pkgs/apple-music-desktop/package.nix
      src=$(nix build --no-link --print-out-paths ".#apple-music-desktop.src")
      base=$(jq -r '.version // empty' "$src/src/package.json")
      if [[ -n $base ]]; then
        sed -i -E "s/^  version = \"[^\"]+-unstable-/  version = \"$base-unstable-/" "$pkg_file"
      else
        echo "warning: no version in src/package.json, keeping nix-update's version" >&2
      fi
    '';
  };

  meta = {
    description = "Electron-based desktop client for Apple Music";
    homepage = "https://github.com/Alex313031/apple-music-desktop";
    license = lib.licenses.bsd3;
    mainProgram = "apple-music-desktop";
    platforms = lib.platforms.linux;
  };
}
