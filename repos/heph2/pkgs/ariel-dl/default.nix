{ fetchurl, fetchFromGitHub, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage rec {
  pname = "ariel-dl";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heph2";
    repo = pname;
    rev = "8b9f4dc7de4fabec46b1557313ef2224937a57e5";
    sha256 = "XglOirJ0XnUZoo+kfFta/l6CDWqPOPR8ttpQWVbq9eo=";
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
