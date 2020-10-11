{ stdenv, fetchgit, fetchsvn, fetchFromGitHub, writeText,
  pkg-config, libusb1, ncurses, which,
  cc65, opencbm,
}:

stdenv.mkDerivation rec {
  name = "nibtools-${version}";
  version = "666";

  # The Subversion repo seems to have a lot of temporary failures, so I made a git clone.
  # Original repo for reference, if you prefer it.
  #src = fetchsvn {
  #  url = "https://c64preservation.com/svn/nibtools/trunk/";
  #  rev = version;
  #  # v637
  #  # sha256 = "0rqfks6xks6khjfc143lzqs1mqkv4b1zch83rxas598nmshgxy13";
  #  # v657
  #  sha256 = "18hs5v05hcsizmpr4r2sm0fv7115kqcxsfr998dw46iawg7f26z6";
  #};

  src = fetchFromGitHub {
    owner = "OpenCBM";
    repo = "nibtools";
    rev = "77ec1e1716b579d23130d78586ef5297f17cd6b7";
    sha256 = "16xh0n7q34h1dgbx9bss05w5lh6lrla31fza7g20fsiyih3bz077";
  };

  patches = [
    ./00-fix-opencbm-path.patch
    ];
  buildInputs = [ pkg-config cc65 opencbm ];
  makefile = "LINUX/Makefile";
  makeFlags = [ "BINDIR=$(out)/bin" "CBM_LNX_PATH=${opencbm.src}/opencbm" ];
  preInstall = ''
    mkdir -p $out/bin
    '';
  postInstall = ''
    mkdir -p $out/share/nibtools
    cat readme.txt > $out/share/nibtools/README
    '';


  hardeningDisable = [ "all" ];

  meta = with stdenv.lib; {
    description = "a disk transfer program designed for copying original disks and converting into the G64 and D64 disk image formats";
    homepage    = https://c64preservation.com/dp.php?pg=nibtools;
    license     = licenses.unfree;
    maintainers = with maintainers; [ tokudan ];
  };
}


