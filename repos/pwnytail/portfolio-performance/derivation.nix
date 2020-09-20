{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
, swt
}:

# missing runtime dep  libwebkitgtk-3.0-0
stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.47.0";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "66cc2bb9bf9b41ae9178eeb1843c117acd0a1ac769df354114b5b61937476250";
  };



  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
  	libsecret
	glib
  ];
  unpackPhase = ''
    tar xvf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r portfolio/ $out
    ln -s $out/portfolio/PortfolioPerformance  $out/bin/PortfolioPerformance
    '';

  meta = with stdenv.lib; {
    homepage = https://www.portfolio-performance.info;
    description = "Portfolio Performance";
    license = licenses.epl10;
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
