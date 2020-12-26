{ stdenv, fetchgit, glibc, libressl }:

stdenv.mkDerivation rec {
  pname = "codemadness-frontends";
  version = "0.4";

  src = fetchgit {
    url = "git://git.codemadness.org/frontends";
    rev = "${version}";
    sha256 = "180j6s305j2yj3g4mld0z8p8gc5fxzrp3y8r71rq3yna78svyr56";
  };

  buildInputs = [
    libressl
  ];

  NIX_LDFLAGS = "-lpthread";

  patchPhase = ''
    sed -i 's/^#FRONTENDS_/FRONTENDS_/g' Makefile
	  sed -i 's/^#LIBTLS_/LIBTLS_/g' Makefile
    sed -i "s/-static//g" Makefile # don't static link or else it segfaults!!
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 duckduckgo/cli $out/bin/duckduckgo-cli
    install -Dm755 duckduckgo/gopher $out/bin/duckduckgo-gopher

    install -Dm755 reddit/cli $out/bin/reddit-cli
    install -Dm755 reddit/gopher $out/bin/reddit-gopher

    install -Dm755 youtube/cgi $out/bin/youtube-cgi
    install -Dm755 youtube/cli $out/bin/youtube-cli
    install -Dm755 youtube/gopher $out/bin/youtube-gopher
  '';

  meta = {
    homepage = "https://git.codemadness.org/frontends/file/README.html";
    description = "Front-ends for some sites";
    license = stdenv.lib.licenses.isc;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = stdenv.lib.platforms.linux; 
  };
}