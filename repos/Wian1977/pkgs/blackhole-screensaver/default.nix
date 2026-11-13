{ lib, stdenv, fetchurl, python3, gtk3, libGL, wrapGAppsHook3,
  gobject-introspection, makeWrapper, desktop-file-utils }:

let
  python = python3.withPackages (ps: with ps; [ pygobject3 python-xlib ]);
in
stdenv.mkDerivation rec {
  pname = "blackhole-screensaver";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/Wian1977/blackholescreensaver/archive/refs/tags/v${version}.tar.gz";
    sha256 = "7bf957d62976dcea1f521cf6c8ad99be51f3c6dc626758c850c8e0c7db0d867b";
  };

  nativeBuildInputs = [ wrapGAppsHook3 gobject-introspection makeWrapper desktop-file-utils ];
  buildInputs = [ gtk3 libGL python ];

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    APP=$out/share/blackhole-screensaver
    mkdir -p $APP $out/bin $out/share/applications
    cp *.py $APP/
    cp *.bin $APP/ 2>/dev/null || true
    cp -r plugin $APP/

    makeWrapper ${python}/bin/python3 $out/bin/blackhole-screensaver       --add-flags "$APP/bh_gl.py"       --prefix LD_LIBRARY_PATH : "${libGL}/lib"
    makeWrapper ${python}/bin/python3 $out/bin/blackhole-daemon       --add-flags "$APP/blackhole-daemon.py"       --prefix LD_LIBRARY_PATH : "${libGL}/lib"

    cat > $out/share/applications/blackhole-screensaver.desktop <<DESK
[Desktop Entry]
Type=Application
Name=Black Hole Screensaver
Comment=Real-physics OpenGL black hole screensaver
Exec=blackhole-screensaver
Icon=blackhole
Categories=Graphics;Utility;
Terminal=false
DESK
    runHook postInstall
  '';

  meta = with lib; {
    description = "Real-physics Schwarzschild black-hole OpenGL screensaver";
    homepage = "https://github.com/Wian1977/blackholescreensaver";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "blackhole-screensaver";
  };
}
