{ stdenv, fetchgit, fetchsvn, fetchFromGitHub, writeText,
  pkg-config, libusb1, ncurses, which,
  cc65, opencbm,
}:

stdenv.mkDerivation rec {
  name = "nibtools-${version}";
  version = "657";

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

  src = fetchgit {
    url = "https://codeberg.org/tokudan/nibtools.git";
    rev = "refs/tags/r${version}";
    sha256 = "18hs5v05hcsizmpr4r2sm0fv7115kqcxsfr998dw46iawg7f26z6";
  };

  patches = [
    (writeText "nibtools-opencbm.patch" ''
diff -Naur /nix/store/1mlxihj4fs5ky1rkjdq86xbaz06kw44h-nibtools-r657/LINUX/Makefile tmp.LCYSARtSWF/LINUX/Makefile
--- /nix/store/1mlxihj4fs5ky1rkjdq86xbaz06kw44h-nibtools-r657/LINUX/Makefile	1970-01-01 01:00:01.000000000 +0100
+++ tmp.LCYSARtSWF/LINUX/Makefile	2020-02-29 20:20:03.990206474 +0100
@@ -1,7 +1,6 @@
 # $Id: Makefile,v 1.1.1.1 2007/01/21 17:15:35 peter Exp $
 
-RELATIVEPATH=../
-include ''${RELATIVEPATH}LINUX/config.make
+include ${opencbm.src}/opencbm/LINUX/config.make
 
 .PHONY: all mrproper clean install uninstall install-files
 
@@ -9,12 +8,12 @@
 PROG = nibread nibwrite nibscan nibconv nibrepair nibsrqtest
 
 all:
-	make -f GNU/Makefile CBM_LNX_PATH="../" linux
+	make -f GNU/Makefile linux
 
 mrproper: clean
 
 clean:
-	make -f GNU/Makefile CBM_LNX_PATH="../" distclean
+	make -f GNU/Makefile distclean
 
 install-files: $(PROG)
 	install -m 755 -s $(PROG) $(BINDIR)
      '')
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


