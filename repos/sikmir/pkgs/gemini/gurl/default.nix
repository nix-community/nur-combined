{ lib, stdenv, fetchFromGitHub, zig }:

stdenv.mkDerivation rec {
  pname = "gurl-unstable";
  version = "2020-12-28";

  src = fetchFromGitHub {
    owner = "MasterQ32";
    repo = "gurl";
    rev = "13e2999a8c86a84ed9b3054f1f7ef9613387b778";
    sha256 = "0yyxgl9kj25frz1m2wwvbrpl83r7w1pkqp52zfm2qhrv6qzjqic7";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig ];

  buildPhase = "HOME=$TMP zig build install";

  installPhase = "install -Dm755 zig-cache/bin/gurl -t $out/bin";

  meta = with lib; {
    description = "A curl-like cli application to interact with Gemini sites";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true; # https://github.com/MasterQ32/gurl/issues/4
  };
}
