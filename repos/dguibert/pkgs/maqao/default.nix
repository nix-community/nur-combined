{
  stdenv,
  requireFile,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  name = "maqao-2.10.14";
  src = requireFile {
    name = "maqao-2.10.14.tar.gz";
    url = "maqao-2.10.14.tar.gz";
    sha256 = "00q6y5pq38cmv2lqg87ak0g6268336amylzcydk9w3pfqxiipmrp";
  };

  buildInputs = [autoPatchelfHook];

  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp bin/maqao $out/bin/

    mkdir -p $out/lib
    cp lib/* $out/lib/
  '';
}
