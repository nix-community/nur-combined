{ lib, fetchFromGitHub }:

let
  pname = "mplus-fonts";
in
fetchFromGitHub {
  name = "${pname}";

  owner = "coz-m";
  repo = "MPLUS_FONTS";
  rev = "f8ce2dd94492ae8713e5b103ccbe3eb94b05b8e6";
  sha256 = "pgj4+J9+Sg8YYg0TcZ0n/XtL+hGeH2vJFz9qZZ9IySQ=";

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

