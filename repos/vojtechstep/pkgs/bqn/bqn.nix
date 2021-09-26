{ lib, stdenv, fetchFromGitHub, nodejs }:

let
  name = "bqn";
  version = "2021-09-26";
in
stdenv.mkDerivation {
  inherit name version;
  src = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "BQN";
    rev = "13bc6cef6702d5e809c99251d4e1f356e046e65d";
    sha256 = "12hvhqsx34q2h934pb0ywqm9cswzrvs827rgsqv12np9vhjfpdam";
  };

  buildInputs = [ nodejs ];

  installPhase = ''
    mkdir -p $out/bin/docs
    install -Dm755 bqn.js $out/bin/bqn
    install -Dm755 docs/bqn.js $out/bin/docs
  '';

  meta = with lib;{
    description = "An APL-like programming language. Self-hosted!";
    homepage = "https://mlochbaum.github.io/BQN/";
    license = licenses.isc;
    maintainers = "VojtechStep";
    platforms = platforms.linux ++ platforms.darwin; # taken from nodejs' platforms
  };
}
