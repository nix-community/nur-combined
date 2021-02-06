{ stdenv, lib, fetchFromGitHub, gawk }:

let
  description = "A list of bitcoin validating nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "5a03842faeaec38ac3bca5175c5415ea57ca5d9c";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "0qm812y0ynhk59a0mi6fwjyljd8bf73zrq1yvqizw997m42496zx";
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
