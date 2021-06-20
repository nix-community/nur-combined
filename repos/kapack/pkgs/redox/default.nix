{ stdenv, lib, fetchFromGitHub, cmake, hiredis, libev }:

stdenv.mkDerivation rec {
  name = "redox";

  src = fetchFromGitHub {
    repo = "redox";
    owner = "mpoquet";
    rev = "e7904da79d5360ba22fbab64b96be167b6dda5f6";
    sha256= "0mmxrjfidcm5fq233wsgjb9rj81hq78rn52c02vwfmz8ax9bc5yg";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hiredis libev ];

  cmakeFlags = ["-Dstatic_lib=OFF"];
  postFixup = ''
    # fix libdir in pkgconfig file (lib64 -> lib)
    sed -i -E 'sW^libdir=(.*)/lib[0-9]{2}Wlibdir=\1/libW' $out/lib*/pkgconfig/redox.pc
  '';

  meta = with lib; {
    description = "Modern, asynchronous, and wicked fast C++11 client for Redis";
    homepage    = https://github.com/hmartiro/redox;
    license     = licenses.asl20;
    platforms   = platforms.all;
    broken = false;

    longDescription = ''
      A fast JSON parser/generator for C++ with both SAX/DOM style API
    '';
  };
}
