{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "swissfileknife";
  version = "1.9.9";

  src = fetchurl {
    url = "mirror://sourceforge/project/${pname}/1-swissfileknife/${version}.0/sfk-${version}.tar.gz";
    hash = "sha256-Sc1zKDSVolT4ZZyw2WmDI5w0YYiSBkwxiwwtGYYceRA=";
  };

  meta = with lib; {
    description = "One hundred command line tools in a small and portable binary";
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
    homepage = "https://sourceforge.net/projects/swissfileknife";
    license = licenses.bsd3;
    mainProgram = "sfk";
  };
}
