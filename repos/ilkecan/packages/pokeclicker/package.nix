{
  lib,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  icoutils,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "pokeclicker";
  version = "0.10.26";

  src = fetchFromGitHub {
    owner = "pokeclicker";
    repo = "pokeclicker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iD2r0TpovKARKn3L3RCIr95jCjcApL4H4BI31Y5/Ej4=";
    # The bundled translation fallback is maintained as a pinned submodule.
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-HC3fmGclhvjA3tSTVndWN5z1K6nG7KX29tRwnC1DGyw=";

  nativeBuildInputs = [
    copyDesktopItems
    icoutils
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    NODE_ENV=production npm exec gulp -- build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/pokeclicker/{electron,game} $out/bin
    cp -r build/. $out/share/pokeclicker/game
    cp ${./main.js} $out/share/pokeclicker/electron/main.js
    cp ${./package.json} $out/share/pokeclicker/electron/package.json

    substituteInPlace $out/share/pokeclicker/electron/main.js \
      --replace-fail '@gameDir@' "$out/share/pokeclicker/game" \
      --replace-fail '@icon@' "$out/share/icons/hicolor/16x16/apps/pokeclicker.png"
    substituteInPlace $out/share/pokeclicker/electron/package.json \
      --replace-fail '@version@' "${finalAttrs.version}"

    icotool -x src/assets/images/favicon.ico
    install -Dm644 favicon_*.png $out/share/icons/hicolor/16x16/apps/pokeclicker.png

    makeWrapper ${lib.getExe electron} $out/bin/pokeclicker \
      --add-flags $out/share/pokeclicker/electron \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "PokéClicker";
      exec = finalAttrs.meta.mainProgram;
      terminal = false;
      type = "Application";
      icon = "pokeclicker";
      comment = finalAttrs.meta.description;
      categories = [ "Game" ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The new and improved version of the popular idle/incremental PokéClicker";
    homepage = "https://pokeclicker.com/";
    license =
      with lib.licenses;
      AND [
        isc # project source code
        mit # translations
        unfree # assets
      ];
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
    mainProgram = "pokeclicker";
  };
})
