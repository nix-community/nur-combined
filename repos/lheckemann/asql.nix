{ stdenv, fetchurl, makeWrapper, perl, perlPackages }:
let version = "1.7"; in
stdenv.mkDerivation rec {
  name = "asql-${version}";
  src = fetchurl {
    url = "https://steve.fi/Software/asql/asql-${version}.tar.gz";
    sha256 = "06nvfjzd45gb8kncr2jvnpa6zmislq7cy058b25a17f02paxjr7h";
  };
  nativeBuildInputs = [makeWrapper];
  buildInputs = [perl perlPackages.DBDSQLite perlPackages.TermReadLineGnu];
  phases = ["unpackPhase" "installPhase" "fixupPhase"];
  installPhase = ''
    install -Dm 0755 bin/asql "$out/libexec/asql"
    mkdir $out/bin
    makeWrapper $out/libexec/asql $out/bin/asql --set PERL5LIB "$PERL5LIB"
  '';
}
