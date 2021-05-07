{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "2021-03-13";

  src = fetchFromGitHub {
    owner = "afify";
    repo = pname;
    rev = "b6063fd0a91a0ee976a09c79cbeb097ba26bfd21";
    hash = "sha256-tRT8snpxXKwOHFT9GoK8xQnu8mQbUfbujyii2paQEaU=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple file manager";
    inherit (src.meta) homepage;
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
