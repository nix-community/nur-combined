{ stdenv, fetchurl, makeWrapper, wrapGAppsHook, autoPatchelfHook, dpkg
, xorg, atk, glib, pango, gdk-pixbuf, cairo, freetype, fontconfig, gtk3
, gnome2, dbus, nss, nspr, alsaLib, cups, expat, udev, libnotify, xdg_utils }:

let
  version = "5.4.4-beta.2";
in stdenv.mkDerivation {
  pname = "ferdi";
  inherit version;
  src = fetchurl {
    #url = "https://github.com/meetfranz/franz/releases/download/v${version}/franz_${version}_amd64.deb";
    url = "https://github.com/getferdi/ferdi/releases/download/v${version}/ferdi_${version}_amd64.deb";
    sha256 = "10lidrg2p594i8wwdpmg46xk1fszr9dq6y5lk34fbpfv3sgcj4il";
  };

  # don't remove runtime deps
  dontPatchELF = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper wrapGAppsHook dpkg ];
  buildInputs = (with xorg; [
    libXi libXcursor libXdamage libXrandr libXcomposite libXext libXfixes
    libXrender libX11 libXtst libXScrnSaver
  ]) ++ [
    gtk3 atk glib pango gdk-pixbuf cairo freetype fontconfig dbus
    gnome2.GConf nss nspr alsaLib cups expat stdenv.cc.cc
  ];
  runtimeDependencies = [ udev.lib libnotify ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out
    ln -s $out/opt/Ferdi/ferdi $out/bin

    # provide desktop item and icon
    cp -r usr/share $out
    substituteInPlace $out/share/applications/ferdi.desktop \
      --replace Exec=\"/opt/Ferdi/ferdi\" Exec=ferdi
  '';

  dontWrapGApps = true;

  postFixup = ''
    # ferdi without an account requires libstdc++ at runtime
    wrapProgram $out/opt/Ferdi/ferdi \
      --prefix PATH : ${xdg_utils}/bin \
      --prefix LD_LIBRARY_PATH : "${stdenv.cc.cc.lib}/lib" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = with stdenv.lib; {
    description = "A free messaging app that combines chat & messaging services into one application";
    homepage = https://getferdi.com;
    license = licenses.free;
    maintainers = [ maintainers.mic92 ];
    platforms = ["x86_64-linux"];
    hydraPlatforms = [];
  };
}
