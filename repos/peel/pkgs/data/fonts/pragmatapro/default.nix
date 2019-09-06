{ stdenv, requireFile, unzip }:

# To use this drv do add PragmataPro.zip to the store:
#   nix-store --add-fixed sha256 PragmataPro-0.826.zip
#   nix-prefetch-url --type sha256 file:///home/peel/PragmataPro-0.826.zip

let
  version = "0.828";
  installPath = "share/fonts/truetype/";
in stdenv.mkDerivation rec {
  name = "pragmatapro-${version}";
  src = requireFile rec {
    name = "PragmataPro-${version}.zip";
    url = "file://$HOME/Dropbox/Software/PragmataPro-${version}.zip";
    sha256 = "116ziblxz6pil74ahdh7zxwj8z848ggbsgmbgrgrivavbjcky763";
  };
  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" ];
  pathsToLink = [ "/share/fonts/truetype/" ];
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
