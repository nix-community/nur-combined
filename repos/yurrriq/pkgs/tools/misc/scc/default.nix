{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "scc";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "boyter";
    repo = "scc";
    rev = "v${version}";
    sha256 = "1wk6s9ga9rkywgqys960s6fz4agwzh3ac2l6cpcr7kca4379s28k";
  };

  goPackagePath = "github.com/boyter/scc";

  meta = with stdenv.lib; {
    description = "A very fast accurate code counter";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.unix;
  };
}
