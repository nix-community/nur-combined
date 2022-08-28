{ lib
, stdenvNoCC
, fakeroot
, pacman
, symlinkJoin
, keyrings ? []
}:

stdenvNoCC.mkDerivation {
  name = "pacman-gnupg";

  src = symlinkJoin {
    name = "pacman-keyrings";
    paths = keyrings;
  };

  nativeBuildInputs = [ fakeroot pacman ];

  installPhase = ''
    export KEYRING_IMPORT_DIR="$src/share/pacman/keyrings"
    GPGDIR=$out/etc/pacman.d/gnupg
    PACMAN_CONF=${pacman}/etc/pacman.conf
    fakeroot pacman-key --config $PACMAN_CONF --gpgdir $GPGDIR --init
    fakeroot pacman-key --config $PACMAN_CONF --gpgdir $GPGDIR --populate
    rm $GPGDIR/S.*
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Generate GPGDir for pacman";
    license = licenses.gpl2Plus;
  };
}
# This derivation is supposed to build locally.
# Don't serve its binary cache.