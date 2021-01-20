{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "lacc";
  version = "20201-01-03";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = "lacc";
    rev = "7c995af815a8e4b44f628021fe0b0a1e84d832c2";
    sha256 = "0mrzfw93n05pqdr0ww46h9nv73dbh4q8pm13qw7i8a2psfgk858d";
  };

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/bin";

  meta = with stdenv.lib; {
    description = "A simple, self-hosting C compiler";
    homepage = "https://github.com/larmel/lacc";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
