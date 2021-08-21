{ fetchurl, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage {
  pname = "Atlas";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/heph2/atlas/releases/download/v1.1/atlas-1.1.tar.gz";
	  sha256 = "1hzladzchnbszyvfp3h1qddgnq30cslsrz55ljw0dc404fsszf6h";
  };
  
  propagatedBuildInputs = with perlPackages; [
    IOSocketSSL XMLRSS URI DateTimeFormatStrptime HTTPDaemon ];

  buildInputs = [shortenPerlShebang];
 
  preBuild = ''
   patchShebangs script/atlas
 '';       

  postInstall = ''
   shortenPerlShebang $out/bin/atlas
  '';

}

