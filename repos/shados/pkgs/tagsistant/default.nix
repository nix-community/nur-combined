{ stdenv, fetchFromGitHub, autoreconfHook, pkg-config
, glib, fuse, libdbi, libdbiDrivers, sqlite, libextractor
}:
stdenv.mkDerivation {
  pname = "tagsistant";
  version = "unstable-2017-02-12";
  src = fetchFromGitHub {
    owner = "StrumentiResistenti"; repo = "Tagsistant";
    rev = "0dabdca1077136b7626a2977410f910689c235b7";
    sha256 = "06pi712grfz790n2v75qbxwdm4dy96h25fyd9jkx3wfm1hc83y5m";
  };
  nativeBuildInputs = [
    autoreconfHook pkg-config
  ];
  buildInputs = [
    glib fuse libdbi libdbiDrivers libextractor
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
  meta = with stdenv.lib; {
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
