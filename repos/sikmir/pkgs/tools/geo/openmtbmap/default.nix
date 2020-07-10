{ stdenv, gmaptool, mkgmap, p7zip, zsh, sources, substituteAll }:
let
  pname = "openmtbmap";
  date = stdenv.lib.substring 0 10 sources.openmtbmap.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.openmtbmap;

  patches = (substituteAll {
    src = ./0001-fix-path.patch;
    inherit gmaptool mkgmap p7zip;
  });

  buildInputs = [ zsh ];

  installPhase = ''
    install -Dm755 create_omtb_garmin_img.sh $out/bin/create_omtb_garmin_img
  '';

  meta = with stdenv.lib; {
    inherit (sources.openmtbmap) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
