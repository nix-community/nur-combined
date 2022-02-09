{ fetchurl, fetchFromGitHub, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage rec {
  pname = "ariel-dl";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heph2";
    repo = pname;
    rev = "c396ba1494a9d6be619d5a5ccc790b6be722e162";
    sha256 = "5ajTiQbdxCKTOCejun1IFnrfd99T80uAbfByDk2CC8A=";	
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
