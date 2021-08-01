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
, imagemagick
}:

let
  icon = "${sources.clash-for-windows-icon.src}[4]";
in
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

    mkdir -p "$out/bin"
    ln -s "$out/opt/clash-for-windows/cfw" "$out/bin/cfw"

    mkdir -p "$out/share/applications"
    substituteAll "${./clash-for-windows.desktop}" "$out/share/applications/clash-for-windows.desktop"

    icon_dir="$out/share/icons/hicolor"
    icon_sizes=("16x16" "24x24" "32x32" "48x48" "256x256")
    for s in "''${icon_sizes[@]}"; do
      echo "create icon \"$s\""
      mkdir -p "$icon_dir/$s/apps"
      ${imagemagick}/bin/convert -resize "$s" "${icon}" "$icon_dir/$s/apps/clash-for-windows.png"
    done
  '';

  meta = with lib; {
    homepage = https://github.com/Fndroid/clash_for_windows_pkg;
    description = "A Windows/macOS/Linux GUI based on Clash and Electron";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
