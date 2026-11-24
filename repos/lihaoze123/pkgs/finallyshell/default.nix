{ lib
, stdenv
, fetchurl
, dpkg
, patchelf
, addDriverRunpath
, makeWrapper
, wrapGAppsHook3
, at-spi2-atk
, at-spi2-core
, cairo
, dbus
, fontconfig
, gdk-pixbuf
, glib
, glib-networking
, gsettings-desktop-schemas
, gtk-layer-shell
, gtk3
, harfbuzz
, libGL
, libX11
, libayatana-appindicator
, libepoxy
, libsecret
, libsoup_3
, pango
, vulkan-loader
, wayland
, webkitgtk_4_1
, xdg-utils
, zlib
,
}:

let
  pname = "finallyshell";
  version = "0.4.0";

  runtimeLibs = [
    at-spi2-atk
    at-spi2-core
    cairo
    dbus
    fontconfig
    gdk-pixbuf
    glib
    gtk-layer-shell
    gtk3
    harfbuzz
    libGL
    libX11
    libayatana-appindicator
    libepoxy
    libsecret
    libsoup_3
    pango
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
    webkitgtk_4_1
    zlib
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/TooonyChen/finallyshell/releases/download/v${version}/finallyshell_${version}_amd64.deb";
    hash = "sha256-xflGTDAxHhfmOjzfPtxMtUyjZigmnoh+ATybbB9/PZ0=";
  };

  nativeBuildInputs = [
    dpkg
    patchelf
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibs ++ [
    glib-networking
    gsettings-desktop-schemas
  ];

  dontConfigure = true;
  dontBuild = true;
  # The upstream binary is a CGO_ENABLED=0 Go (purego) executable built with
  # Go's internal linker; stripping or rewriting DT_RUNPATH via patchelf
  # corrupts its ELF layout and causes an immediate segfault at startup.
  # Patch only the ELF interpreter and provide dlopen libraries via wrapper.
  dontStrip = true;
  dontPatchELF = true;
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/finallyshell" "$out/bin" "$out/share/licenses/${pname}"
    cp -r opt/finallyshell/* "$out/lib/finallyshell/"
    cp -r usr/share/* "$out/share/"

    patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
      "$out/lib/finallyshell/finallyshell"

    install -Dm444 opt/finallyshell/LICENSE.txt "$out/share/licenses/${pname}/LICENSE.txt"
    install -Dm444 opt/finallyshell/THIRD_PARTY_LICENSES.txt "$out/share/licenses/${pname}/THIRD_PARTY_LICENSES.txt"

    substituteInPlace "$out/share/applications/finallyshell.desktop" \
      --replace-fail "Exec=/opt/finallyshell/finallyshell" "Exec=$out/bin/finallyshell"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/lib/finallyshell/finallyshell" "$out/bin/finallyshell" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:$out/lib/finallyshell:${addDriverRunpath.driverLink}/lib" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}"
  '';

  meta = {
    description = "Source-available native SSH client and server monitoring workspace (official prebuilt .deb)";
    homepage = "https://github.com/TooonyChen/finallyshell";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "finallyshell";
  };
}
