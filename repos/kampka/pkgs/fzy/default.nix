{ stdenv, buildPackages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "0.9";
  name = "fzy-${version}";

  src = fetchFromGitHub {
    owner = "jhawthorn";
    repo = "fzy";
    rev = "${version}";
    sha256 = "1f1sh88ivdgnqaqha5ircfd9vb0xmss976qns022n0ddb91k5ka6";
  };

  preConfigure = ''
    export PREFIX="$out"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/jhawthorn/fzy;
    license = licenses.mit;
    description = "A better fuzzy finder";
    platforms = platforms.unix;
  };
}
