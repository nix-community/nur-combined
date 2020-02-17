{ stdenv, fetchzip, ... }:
let
  version = "2.1.0";
in fetchzip {
  name = "iosevka-nerd-${version}";
  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/Iosevka.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/truetype
  '';

  sha256 = "1lyi32bidph0zmyqhikxq0s744dyqqb9fz1gapmkm2bq4pxbh1ja";

  meta = with stdenv.lib; {
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    description = "Iosevka Nerd Font";
    platforms = platforms.all;
  };
}
