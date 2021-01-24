{ stdenv, fetchurl, unzip, mono, gtk2, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "maperitive-bin";
  version = "2.4.3";

  src = fetchurl {
    url = "http://maperitive.net/download/Maperitive-${version}.zip";
    sha256 = "0j9lfc7pik6hzayb4zz3df4x5fzhyf74r47qj8s4d3827r32a6ya";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/maperitive
    cp -r . $out/opt/maperitive

    makeWrapper ${mono}/bin/mono $out/bin/maperitive \
      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath [ gtk2 ]} \
      --run "[ -d \$HOME/.maperitive ] || { cp -r $out/opt/maperitive \$HOME/.maperitive && chmod -R +w \$HOME/.maperitive; }" \
      --add-flags "--desktop \$HOME/.maperitive/Maperitive.exe"
  '';

  meta = with stdenv.lib; {
    description = "Desktop application for drawing maps based on OpenStreetMap and GPS data";
    homepage = "http://maperitive.net/";
    changelog = "http://maperitive.net/updates.xml";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
}
