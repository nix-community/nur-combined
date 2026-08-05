{
  lib,
  stdenv,
  fetchFromGitHub,
  applyPatches,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icloud-mail";
  version = "1.2.0";

  # Upstream last commit: 2024-05-07 (v1.2.0). Patch bumps runtime deps and
  # adapts main.js for electron-context-menu v4 (pure ESM) + current Chromium UA.
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "Swe-HimelRana";
      repo = "icloud-mail";
      rev = "b93ad31147255460308fcf30ee706cfa246d3473";
      hash = "sha256-t4awg1n+ieeOe7H4KnKmECTMHbePWUdm65BXwiAyChE=";
    };
    patches = [ ./update-dependencies.patch ];
    postPatch = ''
      # Prefer the regenerated package-lock.json; yarn.lock is unused under Nix.
      rm -f yarn.lock
    '';
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-eRr7QBBorRAqw3KSiFWbSU2Q0juuAbCk63nRv7xTs3w=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    makeWrapper
    copyDesktopItems
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icloud-mail
    cp -r . $out/share/icloud-mail

    install -Dm644 icon.png \
      $out/share/icons/hicolor/512x512/apps/icloud-mail.png

    makeWrapper ${lib.getExe electron} $out/bin/icloud-mail \
      --add-flags $out/share/icloud-mail \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "icloud-mail";
      exec = "icloud-mail %U";
      icon = "icloud-mail";
      desktopName = "iCloud Mail";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Office"
      ];
      startupWMClass = "icloud-mail";
    })
  ];

  meta = {
    description = "Unofficial desktop app for iCloud Mail";
    homepage = "https://github.com/Swe-HimelRana/icloud-mail";
    license = lib.licenses.isc;
    mainProgram = "icloud-mail";
    platforms = lib.platforms.linux;
  };
})
