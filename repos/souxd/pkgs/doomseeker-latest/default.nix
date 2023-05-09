{ lib, stdenv, mkDerivation, cmake, fetchFromBitbucket, pkg-config, qtbase, qttools, qtmultimedia, zlib, bzip2, xxd }:

mkDerivation {
  pname = "doomseeker";
  version = "1.4.1";

  src = fetchFromBitbucket {
    owner = "Doomseeker";
    repo = "doomseeker";
    rev = "1.4.1";
    sha256 = "0rb6gmkabzxvh48djd4lba73gv80chzmm9nndqq0dn3bi1mpnlrm";
  };

  patches = [ ./add_gitinfo.patch ./dont_update_gitinfo.patch ./fix_paths.patch ];

  nativeBuildInputs = [ cmake qttools pkg-config xxd ];
  buildInputs = [ qtbase qtmultimedia zlib bzip2 ];

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = with lib; {
    homepage = "http://doomseeker.drdteam.org/";
    description = "Multiplayer server browser for many Doom source ports";
    license = licenses.gpl2;
    platforms = platforms.unix;
    broken = true;
  };
}
