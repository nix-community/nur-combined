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
  makeBinaryWrapper,

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
    makeBinaryWrapper
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
    wrapProgram $out/opt/Termius/termius-app \
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
