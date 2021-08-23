{ fetchurl, perlPackages, shortenPerlShebang }:

perlPackages.buildPerlPackage {
  pname = "Atlas";
  version = "0.1";

  src = fetchurl {
    url = "https://github.com/heph2/atlas/releases/download/v0.1/atlas-0.1.tar.gz";
	  sha256 = "143x5gj97w71mdjxz0pc054zvx15yw8nyps8f3xda3kdfr67ybiw";
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

