{ stdenv, fetchhg, autoreconfHook, bison, flex }:

stdenv.mkDerivation rec {
  version = "unstable-2020-07-06";
  pname = "matiec";

  src = fetchhg {
    url = "https://hg.beremiz.org/matiec/";
    rev = "30adcffcf8e6";
    sha256 = "00wrk92zv6rp6rr1wi4kp7jdraj53c5bf1fq6wyws9gv6ycks1l5";
  };

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with stdenv.lib;{
    homepage = "https://beremiz.org";
    description = "IEC 61131-3 compiler";
    license = licenses.gpl3;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
  };
}
