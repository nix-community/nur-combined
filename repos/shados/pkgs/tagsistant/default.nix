{ lib, stdenv, autoreconfHook, pkg-config, pins
, glib, fuse, libdbi, libdbiDrivers, sqlite, libextractor
}:
stdenv.mkDerivation {
  pname = "tagsistant";
  version = "unstable-2017-02-12";
  src = pins.tagsistant.outPath;
  nativeBuildInputs = [
    autoreconfHook pkg-config
  ];
  buildInputs = [
    glib fuse libdbi libdbiDrivers libextractor
  ];
  CFLAGS = [
    # -fnocommon being default in GCC 10+ causes tagsistant build to break with
    # a linker error, see https://gcc.gnu.org/gcc-10/porting_to.html for
    # details
    "-fcommon"
  ];
  prePatch = ''
    # Replace broken aclocal symlinks
    rm -f m4/*
    aclocal --install -I m4

    # Patch to point to libdbi drivers instead of relying on them being in /usr
    substituteInPlace src/sql.c \
      --replace 'dbi_initialize(NULL' 'dbi_initialize("${libdbiDrivers}/lib/dbd/"' \
      --replace 'dbi_initialize_r(NULL' 'dbi_initialize_r("${libdbiDrivers}/lib/dbd/"'
  '';
  meta = with lib; {
    description = "Semantic filesystem for Linux, with relation reasoner, autotagging plugins and a deduplication service";
    longDescription = ''
      Tagsistant is a semantic file system for Linux, a personal tool
      to catalog files using tags (labels, mnemonic informations)
      rather than directories.

      Tagsistant replace the concept of directory with that of tag, but
      since it have to do with directories, it pairs the concept of tag
      with that of directory. So within Tagsistant a tag is a directory
      and a directory is a tag.
    '';
    homepage    = https://tagsistant.net/;
    maintainers = with maintainers; [ arobyn ];
    platforms   =  [ "x86_64-linux" ];
    license     = licenses.gpl2;
  };
}
