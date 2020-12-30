{ stdenv, fetchFromGitHub, gawk }:

let
  description = "A list of bitcoin validating nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "ac427196a0b66c12f30366fe10379b238af2f4e6";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "0pads7hkjdrkkwfspiy1fla6m6zsbbd7dlxgbdskib971va0fhw2";
  };

  installPhase = ''
    ${gawk}/bin/awk -f mknodes.awk <nodes.txt >$out
  '';

  meta = with stdenv.lib; {
    inherit description;
    homepage = https://github.com/emmanuelrosa/bitcoin-onion-nodes;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
