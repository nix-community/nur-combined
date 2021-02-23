{ stdenv, lib, fetchFromGitHub, gawk }:

let
  description = "A list of bitcoin validating nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "bded874aca35ae61026d5a7841fb450a2fa9b0b7";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "10gy6cbgn6xghyjs95dn487xgmzyk3aa88jxanzd9dzpsr2yr0yz";
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
