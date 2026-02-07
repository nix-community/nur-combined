# use master branch instead of 10.0.0 release to circumvent this bug:
# https://github.com/qarmin/czkawka/issues/1716

# see also:
# https://github.com/qarmin/czkawka/pull/1724

# alternative solution is to use new GUI, which only works on NixOS with slint > 1.13 (we're using master since there is no newer release yet 2026-01-26)
# https://github.com/qarmin/czkawka/issues/1720
# https://github.com/slint-ui/slint/issues/10336

{
  lib,
  atk,
  cairo,
  callPackage,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk4,
  pango,
  libGL,
  libxkbcommon,
  wayland,
  pkg-config,
  rustPlatform,
  stdenv,
  testers,
  wrapGAppsHook4,
  xvfb-run,
  versionCheckHook,
}:

let
  rev = "73c912ca50f27194ead59fc14969ee6080696ea9";
  self = rustPlatform.buildRustPackage {
    pname = "czkawka-git";
    version = "10.0.0-git-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "thomas725";
      repo = "czkawka";
      inherit rev;
      hash = "sha256-aqY9huZC2n+XmjIl4oNoq9sZN1ddqz9i1Wz/FmlLCvQ=";
    };

    cargoHash = "sha256-U1hdMWDZ3VOrWzI9gU5FD+YEGxDHJFWFiT/Alt9pLzI=";

    nativeBuildInputs = [
      gobject-introspection
      pkg-config
      wrapGAppsHook4
    ];

    buildInputs = [
      atk
      cairo
      gdk-pixbuf
      glib
      gtk4
      pango
    ];

    strictDeps = true;

    doCheck = false;

    # Desktop items, icons and metainfo are not installed automatically
    postInstall = ''
      install -Dm444 -t $out/share/applications data/com.github.qarmin.czkawka.desktop
      install -Dm444 -t $out/share/icons/hicolor/scalable/apps data/icons/com.github.qarmin.czkawka.svg
      install -Dm444 -t $out/share/icons/hicolor/scalable/apps data/icons/com.github.qarmin.czkawka-symbolic.svg
      install -Dm444 -t $out/share/metainfo data/com.github.qarmin.czkawka.metainfo.xml
    '';

    doInstallCheck = false;

    # Wrap krokiet so it finds the libs it needs
    postFixup = ''
      if [ -x "$out/bin/krokiet" ]; then
        wrapProgram "$out/bin/krokiet" \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              wayland
              libxkbcommon
              libGL
            ]
          }"
      fi
    '';

    meta = {
      homepage = "https://github.com/qarmin/czkawka";
      description = ''
        Simple, fast and easy to use app to remove unnecessary files from your computer.
        This NUR package builds a fork that uses slint (for krokiet GUI) from git master
        to work around upstream issue #1716 / #1720 on NixOS.

        WARNING: This needs rustc >=1.92, nixpkgs 25.11 currently (2026-02-02) only has 1.91, so if you're on NixOS <= 25.11 you need to load rustPlatform from unstable.
      '';
      longDescription = "This builds https://github.com/thomas725/czkawka (which switched from slint 1.13 to git master).";
      license = with lib.licenses; [ mit ];
      mainProgram = "czkawka_gui";
      maintainers = with lib.maintainers; [
        yanganto
        _0x4A6F
      ];
    };
  };
in
self
