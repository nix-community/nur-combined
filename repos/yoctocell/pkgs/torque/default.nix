{ stdenv
, fetchFromGitHub
, sources
, bash
, transmission
}:

stdenv.mkDerivation {
  pname = "torque";
  version = sources.torque.rev;

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "torque";
    rev = sources.torque.rev;
    sha256 = sources.torque.sha256;
  };

  dontBuild = true;

  installPhase = ''
    install -Dm755 -t $out/bin torque
  '';

  meta = with stdenv.lib; {
    inherit (sources.torque) description homepage;
    license = licenses.mit;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
