{ stdenv, system, fetchzip, lib }:

stdenv.mkDerivation rec {
  pname = "wd";
  version = "1.1.0";
  src = fetchzip {
    url = "https://github.com/kakkun61/wd/tarball/${version}";
    sha256 = "sha256-WNwsgSOcYVfXnJ7/DayvlE490Jheum9gCkoEdnGdggM=";
    extension = "tar.gz";
  };
  buildPhase = "make -C linux";
  installPhase = "make -C linux install out=$out";
  meta = with lib; {
    homepage = https://github.com/kakkun61/wd;
    changelog = "https://github.com/kakkun61/wd/releases/tag/${version}";
    license = licenses.gpl3;
    maintainers = [
      { name = "Kazuki Okamoto (岡本和樹)"; }
    ];
    platforms = platforms.linux ++ platforms.darwin;
    broken = true;
  };
}
