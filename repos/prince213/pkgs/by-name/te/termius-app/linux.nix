{
  pname,
  version,
  src,
  meta,

  lib,
  stdenvNoCC,

  # nativeBuildInputs
  autoPatchelfHook,
  dpkg,
  makeWrapper,

  # buildInputs
  alsa-lib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libsecret,
  nss,
  udev,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    ;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    gtk3
    libdrm
    libgbm
    libsecret
    nss
  ];

  postPatch = ''
    substituteInPlace usr/share/applications/termius-app.desktop \
      --replace-fail "Exec=/opt" "Exec=$out/opt"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r opt usr/share $out/
    ln -s $out/opt/Termius/termius-app $out/bin/

    runHook postInstall
  '';

  postFixup = ''
    # https://github.com/NixOS/nixpkgs/issues/551645
    wrapProgramShell $out/opt/Termius/termius-app \
      --run 'case ":''${XDG_CURRENT_DESKTOP:-}:" in *:KDE:*) termiusKdeWayland=1 ;; *) unset termiusKdeWayland ;; esac' \
      --add-flags "\''${WAYLAND_DISPLAY:+\''${termiusKdeWayland:+--force-device-scale-factor=1}}" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          udev
        ]
      }
  '';

  meta = meta // {
    mainProgram = "termius-app";
  };
}
