{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
}:

# missing runtime dep  libwebkitgtk-3.0-0
stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.46.6";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "cb64cb8e13204370dd1748c227373751527f9c4391ceb55d612336923d74c535";
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
