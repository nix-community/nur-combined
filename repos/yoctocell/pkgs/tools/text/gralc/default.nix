{ stdenv
, fetchFromGitHub
, sources
, pythonPackages
}:

stdenv.mkDerivation {
  pname = "gralc";
  version = "git";

  src = fetchFromGitHub {
    owner = "yoctocell";
    repo = "gralc";
    rev = sources.gralc.rev;
    sha256 = sources.gralc.sha256;
  };

  buildInputs = with pythonPackages; [ python ];

  dontBuild = true;

  installPhase = ''
    install -D src/gralc.py $out/bin/gralc.py
    install -D doc/gralc.1 $out/share/man/man1/gralc.1
  '';

  meta = with stdenv.lib; {
    inherit (sources.gralc) description homepage;
    license = licenses.unlicense;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
