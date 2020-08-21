{ stdenv
, fetchFromGitHub
, sources
}:

stdenv.mkDerivation rec {
  pname = "pash";
  version = "git";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "pash";
    rev = sources.pash.rev;
    sha256 = sources.pash.sha256;
  };

  dontBuild = true;

  installPhase = ''
  install -Dm755 -t $out/bin pash
  '';
  
  meta = with stdenv.lib; {
    inherit (sources.pash) description homepage;
    license = licenses.mit;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
