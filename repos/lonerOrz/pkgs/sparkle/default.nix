{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  nss,
  nspr,
  alsa-lib,
  openssl,
  webkitgtk_4_1,
  udev,
  libayatana-appindicator,
  libGL,
  musl,
}:

let
  sources = import ./sources.nix;
  systemSrc = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "sparkle";
  version = "1.6.14";

  src = fetchurl {
    url = systemSrc.url;
    hash = systemSrc.hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    musl
    nss
    nspr
    alsa-lib
    openssl
    webkitgtk_4_1
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out/opt
    cp -r usr/share $out/share
    substituteInPlace $out/share/applications/sparkle.desktop \
      --replace-fail "/opt/sparkle/sparkle" "sparkle"
    ln -s $out/opt/sparkle/sparkle $out/bin/sparkle
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
          udev
          libayatana-appindicator
        ]
      } $out/opt/sparkle/sparkle
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Another Mihomo GUI";
    homepage = "https://github.com/xishang0128/sparkle.git";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "sparkle";
  };
}
