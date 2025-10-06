{
  lib,
  stdenv,
  fetchFromGitHub,
  gmaptool,
  mkgmap,
  p7zip,
  zsh,
  replaceVars,
}:

stdenv.mkDerivation {
  pname = "openmtbmap";
  version = "2020-06-10";

  src = fetchFromGitHub {
    owner = "btittelbach";
    repo = "openmtbmap_openvelomap_linux";
    rev = "de24cd5d4168d8571c544ac42c51883af957a01a";
    hash = "sha256-J09SYLk869pQYeoGfuY9PFIOU+/W9w22kKwAkVpvkNI=";
  };

  patches = [
    (replaceVars ./0001-fix-path.patch {
      inherit gmaptool mkgmap p7zip;
    })
  ];

  buildInputs = [ zsh ];

  installPhase = ''
    install -Dm755 create_omtb_garmin_img.sh $out/bin/create_omtb_garmin_img
  '';

  meta = {
    description = "Linux script to extract and compile garmin *.img map files from openmtbmap.org or openvelomap.org downloads";
    homepage = "https://github.com/btittelbach/openmtbmap_openvelomap_linux";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
