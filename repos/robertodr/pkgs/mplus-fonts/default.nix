{ lib, fetchFromGitHub }:

let
  pname = "mplus-fonts";
in
fetchFromGitHub {
  name = "${pname}";

  owner = "coz-m";
  repo = "MPLUS_FONTS";
  rev = "8690be3625964d9992e7be4bc3e1a61a80161cc6";
  sha256 = "2uxVzQ2xKnkIU47I9epfM3DrKkuWQjns3U/kc4zN8sQ=";

  postFetch = ''
    mkdir -p $out/share/fonts/{truetype,opentype}/${pname}
    mv $out/fonts/ttf/* $out/share/fonts/truetype/${pname}
    mv $out/fonts/otf/* $out/share/fonts/opentype/${pname}
    shopt -s extglob dotglob
    rm -rf $out/!(share)
    shopt -u extglob dotglob
  '';

  meta = with lib; {
    description = "M+ Outline Fonts (GitHub release)";
    longDescription = "A little nifty font family for everyday use.";
    homepage = "https://mplusfonts.github.io";
    maintainers = with maintainers; [ henrytill uakci robertodr ];
    platforms = platforms.all;
    license = licenses.ofl;
  };
}
