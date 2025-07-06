{
  fetchurl,
  lib,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "hello-jon";
  version = "2.12.2";

  src = fetchurl {
    url = "mirror://gnu/hello/hello-${version}.tar.gz";
    hash = "sha256-WpqZbcKSzCTc9BHO6H6S9qrluNE72caBm0x6nc4IGKs=";
  };

  postPatch = ''
    sed -i -e 's/Hello, world!/Hello, Jon!/' src/hello.c
  '';

  # fails due to patch
  doCheck = false;

  doInstallCheck = true;

  # Give hello some install checks for testing purpose.
  postInstallCheck = ''
    stat "''${!outputBin}/bin/${meta.mainProgram}"
  '';

  meta = {
    description = "Program that produces a familiar, friendly greeting";
    longDescription = ''
      GNU Hello is a program that prints "Hello, world!" when you run it.
      It is fully customizable.
    '';
    homepage = "https://www.gnu.org/software/hello/manual/";
    changelog = "https://git.savannah.gnu.org/cgit/hello.git/plain/NEWS?h=v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ stv0g ];
    mainProgram = "hello";
    platforms = lib.platforms.all;
  };
}
