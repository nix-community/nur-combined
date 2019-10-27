{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "risk-of-rain-mod-loader-${version}";
  version = "0.1.3-hotfix1";

  src = fetchurl {
    url = "https://cdn.discordapp.com/attachments/453980407600250881/532772338656346112/RoRML_Launcher.exe";
    sha256 = "0zdizvw8rq8pfn24hv5pqnm6gwfslyqwnll2y8cacf1i422gka0q";
  };

  outputs = [ "bin" "dev" "devdoc" "out" ];
}
