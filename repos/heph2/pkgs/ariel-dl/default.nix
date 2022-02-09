{ fetchurl, fetchFromGitHub, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage rec {
  pname = "ariel-dl";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "heph2";
    repo = pname;
    rev = "cfda09149f1d6f44f00fb6e6285d9e4aaba5b3e6";
    sha256 = "54WCkE3Ielb83AxjAsJrXFI5hECAPYoKDc+tGUyqdZM=";
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
