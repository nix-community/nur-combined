{ stdenv, fetchFromGitHub, zig }:

stdenv.mkDerivation {
  pname = "gurl-unstable";
  version = "2020-09-19";

  src = fetchFromGitHub {
    owner = "MasterQ32";
    repo = "gurl";
    rev = "e5a61b2db685a53cdbdfb1c6ac160e938683d4ec";
    sha256 = "1y738ip0b6ck0ibybibqw8dlx37mrqamygvm81jv9wqp1sxsi7gb";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig ];

  buildPhase = "HOME=$TMP zig build install";

  installPhase = "install -Dm755 zig-cache/bin/gurl -t $out/bin";

  meta = with stdenv.lib; {
    description = "A curl-like cli application to interact with Gemini sites";
    homepage = "https://github.com/MasterQ32/gurl";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true; # https://github.com/MasterQ32/gurl/issues/4
  };
}
