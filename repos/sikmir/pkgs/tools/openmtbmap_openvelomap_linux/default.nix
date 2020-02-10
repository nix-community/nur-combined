{ stdenv, gmaptool, mkgmap, p7zip, zsh, openmtbmap_openvelomap_linux }:

stdenv.mkDerivation rec {
  pname = "openmtbmap_openvelomap_linux";
  version = stdenv.lib.substring 0 7 src.rev;
  src = openmtbmap_openvelomap_linux;

  patches = [ ./0001-fix-path.patch ];

  buildInputs = [ gmaptool mkgmap p7zip zsh ];

  postPatch = ''
    substituteInPlace create_omtb_garmin_img.sh \
      --replace "%gmaptool%" "${gmaptool}" \
      --replace "%mkgmap%" "${mkgmap}" \
      --replace "%7z%" "${p7zip}/bin/7z"
  '';

  installPhase = ''
    install -Dm755 create_omtb_garmin_img.sh "$out/bin/create_omtb_garmin_img"
  '';

  meta = with stdenv.lib; {
    description = openmtbmap_openvelomap_linux.description;
    homepage = openmtbmap_openvelomap_linux.homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
