{ lib, fetchFromGitHub }:

let
  pname = "mplus-fonts";
in
fetchFromGitHub {
  name = "${pname}";

  owner = "coz-m";
  repo = "MPLUS_FONTS";
  rev = "f605e3524130b8d814911d869315bc4fd4c2148c";
  sha256 = "ZGZxD2RRXDYRq82VvkO18BaQVpR9yj+z+pGR4O7ehnc=";

  postFetch = ''
    mkdir -p $out/share/fonts/{truetype,opentype}/${pname}
    mv $out/fonts/ttf/* $out/share/fonts/truetype/${pname}
    mv $out/fonts/otf/* $out/share/fonts/opentype/${pname}
    shopt -s extglob dotglob
    rm -rf $out/!(share)
    shopt -u extglob dotglob
  '';

  meta = with lib; {
    description = " M + Outline Fonts (GitHub release) ";
    longDescription = "
    A
    little
    nifty
    font
    family
    for
    everyday
    use.";
    homepage = " https://mplusfonts.github.io ";
    maintainers = with maintainers; [ henrytill uakci robertodr ];
    platforms = platforms.all;
    license = licenses.ofl;
  };
}

