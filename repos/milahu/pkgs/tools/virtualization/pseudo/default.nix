{ lib
, stdenv
, fetchgit
, sqlite
, python3
}:

stdenv.mkDerivation rec {
  pname = "pseudo";
  version = "1.9.0-unstable-2024-05-26";

  src = fetchgit {
    url = "https://git.yoctoproject.org/pseudo";
    rev = "e11ae91da7d0711f5e33ea9dfbf1875dde3c1734";
    hash = "sha256-wA+vE5zRTymjYA4EwAulpYqMWwMcgyL+VOaRid5qfbc=";
  };

  nativeBuildInputs = [
    python3
  ];

  postPatch = ''
    patchShebangs .
    # dont append with-sqlite-lib to with-sqlite
    substituteInPlace configure Makefile.in \
      --replace-fail \
        '$(SQLITE)/$(SQLITE_LIB)' \
        '$(SQLITE_LIB)'
    # make this a fatal error to avoid deadloop
    substituteInPlace pseudo_util.c \
      --replace-fail \
        "pseudo_diag(\"help: can't open log file %s: %s\n\", pseudo_path, strerror(errno));" \
        "pseudo_diag(\"Can't open log file %s: %s\n\", pseudo_path, strerror(errno)); exit(1);"
  '';

  configureFlags = [
    "--with-sqlite=${sqlite.dev}"
    "--with-sqlite-lib=${sqlite.out}/lib"
  ];

  postInstall = ''
    mkdir -p $out/share/man/man1
    cp -v *.1 $out/share/man/man1
  '';

  meta = with lib; {
    description = "run a command in a virtual root environment";
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
    # see also
    # https://manpages.debian.org/bookworm/pseudo/pseudo.1.en.html
    # https://salsa.debian.org/debian/pseudo
    homepage = "https://git.yoctoproject.org/pseudo";
    license = licenses.gpl2;
  };
}
