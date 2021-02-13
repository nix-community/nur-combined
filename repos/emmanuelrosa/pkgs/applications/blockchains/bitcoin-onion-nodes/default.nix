{ stdenv, lib, fetchFromGitHub, gawk }:

let
  description = "A list of bitcoin validating nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "48d63d2388ee9d3ef32d1063a2ad119b948577ce";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "0icb65l5q5f90w1bsakz24mri01kblq0s6b3ym94829cyys5isvx";
  };

  installPhase = ''
    ${gawk}/bin/awk -f mknodes.awk <nodes.txt >$out
  '';

  meta = with lib; {
    inherit description;
    homepage = https://github.com/emmanuelrosa/bitcoin-onion-nodes;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
