{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "samurai";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "michaelforney";
    repo = pname;
    rev = version;
    sha256 = "0d5i5nxfaznargqncnzpvxz9v91hy1kp9ncargc57nigdp2mjs2m";
  };

  makeFlags = [ "DESTDIR=" "PREFIX=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "ninja-compatible build tool written in C";
    license = with licenses; [ mit asl20 ]; # see LICENSE
    maintainers = with maintainers; [ dtzWill ];
  };
}
