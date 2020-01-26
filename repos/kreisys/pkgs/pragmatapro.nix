{ stdenv, requireFile, unzip }:

# To use this drv do add PragmataPro.zip to the store:
#   nix-store --add-fixed sha256 PragmataPro0.828-2.zip
#   nix-prefetch-url --type sha256 file:///home/peel/PragmataPro0.828-2.zip

let
  version = "0.828-2";
  installPath = "share/fonts/truetype/";
in stdenv.mkDerivation rec {
  name = "pragmatapro-${version}";
  src = requireFile rec {
    name = "PragmataPro${version}.zip";
    url = "file://path/to/${name}";
    sha256 = "19q6d0dxgd9k2mhr31944wpprks1qbqs1h5f400dyl5qzis2dji3";
  };
  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" ];
  pathsToLink = [ "/share/fonts/truetype/" ];
  sourceRoot = ".";
  installPhase = ''
    install_path=$out/${installPath}
    mkdir -p $install_path
    find . -name "*.ttf" -exec cp {} $install_path \;
  '';
  meta = with stdenv.lib; {
    homepage = "https://www.fsd.it/shop/fonts/pragmatapro/";
    description = ''
      PragmataPro™ is a condensed monospaced font optimized for screen,
      designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering
    '';
    platforms = platforms.all;
    license   = licenses.unfree;
  };
}
