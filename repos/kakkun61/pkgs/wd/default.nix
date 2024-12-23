{ stdenv, system, fetchzip, lib }:

let
  targets = {
    x86_64-linux = "x64-linux";
    x86_64-darwin = "x64-macos";
  };
in
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
    maintainers = [ maintainers.kakkun61 ];
    platforms = platforms.all;
    broken = true;
  };
}
