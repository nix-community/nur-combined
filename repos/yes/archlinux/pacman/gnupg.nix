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

  meta.description = "Generate GPGDir for pacman";
}
# WARNING: This derivation generates a private key that might be reproducible,
# or even exist in a binary cache. Use it at your own risk.