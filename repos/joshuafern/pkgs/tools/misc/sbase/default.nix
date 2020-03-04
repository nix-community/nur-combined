{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "unstable-2020-01-21";

  src = fetchgit {
    url = "git://git.suckless.org/${pname}";
    rev = "971c573e873d34c10d2467d682d7934f39cb2a25";
    sha256 = "19cr9f94f51hlpdaprihqyla89aifzfilajsvqv8x67zi235xc1b";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "suckless unix tools";
    license = licenses.mit;
    #maintainers = with maintainers; [ dtzWill ];
  };
}
                                              
