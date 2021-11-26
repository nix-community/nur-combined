{ lib, stdenv, fetchFromGitHub, libX11 }:

stdenv.mkDerivation rec {
  pname = "pista";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "xandkar";
    repo = pname;
    rev = version;
    sha256 = "sha256-Bdi9gLG4KG1BEk8BcU0FYg6Si7SF8YKN5iIafkTqlWk=";
  };

  buildInputs = [ libX11 ];

  installPhase = ''
    install -Dm755 pista -t $out/bin
  '';

  meta = with lib; {
    description = "Piped status: the ii of status bars!";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
