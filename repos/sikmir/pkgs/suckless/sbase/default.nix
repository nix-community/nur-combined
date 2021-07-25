{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "2021-07-17";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "61be841f5cc4019890c769cec33744616614ea10";
    sha256 = "sha256-seBzD2cHlJqxQrQBiBtfLGkdQxiBCpQiKAvAx2n2swQ=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "suckless unix tools";
    homepage = "https://tools.suckless.org/sbase/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
