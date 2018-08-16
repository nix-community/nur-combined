{ stdenv, requireFile, unzip }:

# To use this drv do add PragmataPro.zip to the store:
#   nix-store --add-fixed sha256 PragmataPro-0.826.zip
#   nix-prefetch-url --type sha256 file:///home/peel/PragmataPro-0.826.zip

let
  version = "0.826";
  installPath = if stdenv.isDarwin then "Library/Fonts/" else "share/fonts/truetype/";
in stdenv.mkDerivation rec {
  name = "pragmatapro-${version}";
  src = requireFile rec {
    name = "PragmataPro-${version}.zip";
    url = "file://path/to/${name}";
    sha256 = "05r2xkkzgdpcas244yw75g8ifsz3b6ksabsxpa02fx93bz0qf023";
  };
  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" ];
  sourceRoot = ".";
  installPhase = ''
    install_path=$out/${installPath}
    mkdir -p $install_path
    find 'Pragmata Pro Family' -name "*.ttf" -exec cp {} $install_path \;
  '';
  meta = with stdenv.lib; {
    homepage = "https://www.fsd.it/shop/fonts/pragmatapro/";
    description = ''
      PragmataPro™ is a condensed monospaced font optimized for screen,
      designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering
    '';
    platforms = platforms.all;
    broken = true;
  };
}
