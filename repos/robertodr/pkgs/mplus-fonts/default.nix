{
  lib,
  fetchFromGitHub,
}: let
  pname = "mplus-fonts";
in
  fetchFromGitHub {
    name = "${pname}";

    owner = "coz-m";
    repo = "MPLUS_FONTS";
    rev = "86367f2af8794a113df290d2162fd65339265b1d";
    sha256 = "sha256-Mck9aBpVYksTR/OSbFoRi5bLE3eEQlV3qfhWHiWZEuk=";

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
      maintainers = with maintainers; [henrytill uakci robertodr];
      platforms = platforms.all;
      license = licenses.ofl;
    };
  }
