{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
}:

# missing runtime dep  libwebkitgtk-3.0-0
stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.46.3";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "c6a4ee6861843eeca4550c04d8806808be7043e75513ed399bc7555c3dd8c308";
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
