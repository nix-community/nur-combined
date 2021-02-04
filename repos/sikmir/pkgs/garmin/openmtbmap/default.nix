{ lib, stdenv, gmaptool, mkgmap, p7zip, zsh, sources, substituteAll }:

stdenv.mkDerivation {
  pname = "openmtbmap";
  version = lib.substring 0 10 sources.openmtbmap.date;

  src = sources.openmtbmap;

  patches = (substituteAll {
    src = ./0001-fix-path.patch;
    inherit gmaptool mkgmap p7zip;
  });

  buildInputs = [ zsh ];

  installPhase = ''
    install -Dm755 create_omtb_garmin_img.sh $out/bin/create_omtb_garmin_img
  '';

  meta = with lib; {
    inherit (sources.openmtbmap) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
