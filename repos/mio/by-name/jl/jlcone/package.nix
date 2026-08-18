{
  lib,
  stdenv,
  dpkg,
  electron_43,
  fetchurl,
  makeWrapper,
}:

let
  electron = electron_43;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jlcone";
  version = "1.0.67";

  src = fetchurl {
    url = "https://rs.jlcpcb.com/static/APP/app_version/jlcone-${finalAttrs.version}.deb";
    hash = "sha256-2ab9InOz9UCxUwxvGxiN6xrN1YPV7hdSJAVd/P4AVIM=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Install only the app resources — no bundled Electron binary needed
    install -dm755 "$out/lib/jlcone"
    cp -a opt/JLCONE/resources/. "$out/lib/jlcone/resources/"
    cp -a opt/JLCONE/locales "$out/lib/jlcone/locales"

    if [ -d usr/share ]; then
      cp -a usr/share/. "$out/share/"
    fi

    # Fix the desktop file to point to the wrapper binary
    if [ -f "$out/share/applications/jlcone.desktop" ]; then
      substituteInPlace "$out/share/applications/jlcone.desktop" \
        --replace-warn "/opt/JLCONE/jlcone" "jlcone"
    fi

    makeWrapper ${lib.getExe electron} "$out/bin/jlcone" \
      --add-flags "$out/lib/jlcone/resources/app.asar" \
      --add-flags "--no-sandbox" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  meta = {
    description = "JLCPCB desktop client (JLCONE)";
    longDescription = ''
      JLCONE is the official desktop client for JLCPCB, the PCB prototyping
      and assembly service. Runs on nixpkgs Electron (upstream ships Electron 35;
      no native node modules so a newer Electron major is compatible).
    '';
    homepage = "https://jlcpcb.com/download";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "jlcone";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
