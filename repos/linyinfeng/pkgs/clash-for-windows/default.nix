{ sources
, system
, stdenv
, lib
, autoPatchelfHook
, xlibs
, xorg
, gtk3
, pango
, at-spi2-atk
, nss
, libdrm
, alsaLib
, mesa
, libudev
, libappindicator
}:

stdenv.mkDerivation rec {
  inherit (sources.clash-for-windows) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    gtk3
    pango
    at-spi2-atk
    nss
    libdrm
    alsaLib
    mesa
  ] ++ (with xlibs; [
    libXext
    libXcomposite
  ]) ++ (with xorg; [
    libXrandr
    libxshmfence
    libXdamage
  ]);

  runtimeDependencies = [
    libappindicator
    libudev
  ];

  installPhase = ''
    mkdir -p "$out/opt"
    cp -r . "$out/opt/clash-for-windows"
  '';

  meta = with lib; {
    homepage = https://github.com/Fndroid/clash_for_windows_pkg;
    description = "A Windows/macOS/Linux GUI based on Clash and Electron";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
