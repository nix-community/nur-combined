{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
}:

# missing runtime dep  libwebkitgtk-3.0-0
stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.48.1";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "abbde33e6643f1b8d55c4a9c213308691bf291951d3ccd7136fb3dfa22b91d76";
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
