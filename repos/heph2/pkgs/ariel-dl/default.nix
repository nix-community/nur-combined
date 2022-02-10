{ fetchurl, fetchFromGitHub, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage rec {
  pname = "ariel-dl";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heph2";
    repo = pname;
    rev = "868a6cbf98249a140bccfc24e0e8dd9ec27a4453";
    sha256 = "P/W5q9vELbk59VGaOLe7uN9bKLpcBLwnpD9DYBG0iAM=";	
  };

  propagatedBuildInputs = with perlPackages;
    [
      WWWMechanize MojoDOM58 HTTPCookies GetoptLong Env LWPProtocolHttps
    ];

  buildInputs = [shortenPerlShebang];

  installPhase = ''
               perl Makefile.PL PREFIX=$out
               make
               make install
               '';

  preBuild = ''
   patchShebangs script/ariel-dl
 '';

  postInstall = ''
   shortenPerlShebang $out/bin/ariel-dl
  '';
}
