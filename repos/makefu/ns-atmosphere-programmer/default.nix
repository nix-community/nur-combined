{ stdenv, fetchzip
, makeWrapper
, autoPatchelfHook
, xlibs
, gnome3
, libpng12
}:
stdenv.mkDerivation rec {
  name = "ns-atmosphere-programmer-${version}";
  version = "0.1";

  src = fetchzip {
    url = "https://archive.org/download/ns-atmosphere-programmer/ns-atmosphere-programmer-ubuntu-64bit-v01.zip";
    # original source: http://www.ns-atmosphere.com/media/content/ns-atmosphere-programmer-ubuntu-64bit-v01.zip
    sha256 = "1cnyydsmrcpfwpdiry7qybh179499wpbvlzq5rk442hq9ak416ri";
  };

  buildInputs = with xlibs; [ libX11 libXxf86vm libSM gnome3.gtk libpng12 ];
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  installPhase = ''
    install -D -m755 NS-Atmosphere $out/bin/NS-Atmosphere
    wrapProgram $out/bin/NS-Atmosphere --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
--suffix XDG_DATA_DIRS : '${gnome3.defaultIconTheme}/share'
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Payload programmer for ns-atmosphere injector for nintendo switch";
    homepage = http://www.ns-atmosphere.com;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
    license = with licenses; [ unfree ];
  };

}
