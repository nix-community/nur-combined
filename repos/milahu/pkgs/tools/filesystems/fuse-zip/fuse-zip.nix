{ lib
, stdenv
, fetchFromBitbucket
, fuse
, pkg-config
, libzip
}:

stdenv.mkDerivation rec {
  pname = "fuse-zip";
  version = "0.7.2";

  # https://bitbucket.org/agalanin/fuse-zip
  # https://github.com/refi64/fuse-zip
  # https://github.com/milahu/fuse-zip
  src = fetchFromBitbucket {
    owner = "agalanin";
    repo = "fuse-zip";
    rev = version;
    hash = "sha256-o1OEOAmo0r/qUyKTgpvJe2XDWgpvash2+oyqdiEq2a8=";
  };

  makeFlags = [
    "_FILE_OFFSET_BITS=64"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fuse
    libzip
  ];

  # fix: warning _FORTIFY_SOURCE requires compiling with optimization (-O)
  # fix: mkdir: cannot create directory '/usr': Permission denied
  postPatch = ''
    find . -name Makefile | xargs sed -i "s/ -O0 / /; s|^prefix=/usr/local$|prefix=$out|"
  '';

  meta = with lib; {
    description = "";
    homepage = "https://bitbucket.org/agalanin/fuse-zip";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
