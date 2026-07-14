{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icloud-mail";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Swe-HimelRana";
    repo = "icloud-mail";
    rev = "b93ad31147255460308fcf30ee706cfa246d3473";
    hash = "sha256-t4awg1n+ieeOe7H4KnKmECTMHbePWUdm65BXwiAyChE=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    npmFlags = [ "--include=dev" ];
    hash = "sha256-l5/YiIY+pMGcW+bRhZ9He3KiaYmhaq7qWxxaN+fIZtc=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    makeWrapper
    copyDesktopItems
    python3
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmInstallFlags = [
    "--omit=dev"
  ];

  postPatch = ''
        python3 - <<'PY'
    import json
    from pathlib import Path

    path = Path("package.json")
    data = json.loads(path.read_text())
    dev = data.get("devDependencies", {})
    if "electron-builder" in dev:
        dev.pop("electron-builder", None)
        if dev:
            data["devDependencies"] = dev
        else:
            data.pop("devDependencies", None)
        path.write_text(json.dumps(data, indent=2) + "\n")
    PY
  '';

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
