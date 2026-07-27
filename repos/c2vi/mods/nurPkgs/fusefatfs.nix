{ stdenv
, fetchFromGitHub
, cmake
, lib
, pkg-config
, fuse
}:

stdenv.mkDerivation rec {
	name = "fusefatfs";

	src = fetchFromGitHub {
		owner = "virtualsquare";
		repo = "fusefatfs";
    rev = "4bcc1cad3a220cdc09b55609a16cfeb11caa349b";
    sha256 = "sha256-7y30iPwGiE4/PKZX8HhUfa2PaqV4y+zUP57xlD961kg=";
	};

  nativeBuildInputs = [
   cmake
   pkg-config
   fuse
  ];
  
  buildInputs = [
  ];

  meta = with lib; {
    description = "mount FAT file systems with FUSE";
    longDescription = ''
      This repository generates both the fusefatfs command for FUSE (Filesystem in Userspace) and the plug-in submodule for VUOS.
    '';
    homepage = "https://github.com/virtualsquare/fusefatfs";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
