{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "samurai";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "michaelforney";
    repo = pname;
    rev = version;
    sha256 = "1m4yjkyjm278399hj02vs6nzpll1zxr72c62rhx08gsq755q3ncs";
  };

  makeFlags = [ "DESTDIR=" "PREFIX=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "ninja-compatible build tool written in C";
    license = with licenses; [ mit asl20 ]; # see LICENSE
    maintainers = with maintainers; [ dtzWill ];
  };
}
