{ lib, stdenv, fetchFromGitHub, perl }:
stdenv.mkDerivation rec {
  version = "0.4.2";
  name = "any2fasta-${version}";

  src = fetchFromGitHub {
    owner = "tseemann";
    repo = "any2fasta";
    rev = "v${version}";
    sha256 = "sha256:0z7kxq6gbpz84gxypds5kv8p8sr79gqcrmssnick6znb7lavsrih";
  };

  buildInputs = [ perl ];

  installPhase = ''
    install -d $out/bin
    install -t $out/bin any2fasta
  '';

  meta = {
    platforms = lib.platforms.unix;
  };
}
