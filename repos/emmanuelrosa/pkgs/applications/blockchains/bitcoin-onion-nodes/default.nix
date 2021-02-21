{ stdenv, lib, fetchFromGitHub, gawk }:

let
  description = "A list of bitcoin validating nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "d92b798659b88231eb6d5bb3b134794d76738104";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "1x54rlr7mhnx5mwsn6491accagzpqh4w5x66p0zyk7wzfzpjwn3a";
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
