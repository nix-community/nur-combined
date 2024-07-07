{ lib, perlPackages, fetchurl, mozjpeg, shortenPerlShebang }:

perlPackages.buildPerlPackage rec {
  pname = "renrot";
  version = "1.2.0";
  src = fetchurl {
    url = "https://download.gnu.org.ua/pub/release/renrot/${pname}-${version}.tar.gz";
    sha256 = "sha256-o/cReHQiKSaTI4V5osE56KxjZ+CZraCBW2sFA4X4hq4=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [ shortenPerlShebang ];
  propagatedBuildInputs = [
    perlPackages.ImageExifTool
    mozjpeg
  ];

  postInstall = ''
   shortenPerlShebang $out/bin/renrot
  '';

  meta = with lib; {
    description = "Utility to renames files according the flexible name template";
    homepage = "https://puszcza.gnu.org.ua/projects/renrot/";
    license = licenses.artistic2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.unix;
  };
}
