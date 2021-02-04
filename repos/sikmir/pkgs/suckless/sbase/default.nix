{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "2021-01-15";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "7ef4038fb5b93e63f4223ab9f222526130a1e14f";
    sha256 = "0bmri69wi8vi3g8q5fqhwdvwxf4d9r4mhnbwzibr6r70mhcwhiln";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "suckless unix tools";
    homepage = "https://tools.suckless.org/sbase/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
