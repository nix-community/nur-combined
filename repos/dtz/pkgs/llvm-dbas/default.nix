{ stdenv, fetchFromGitHub, cmake, llvm }:

let
  srcinfo = {
    version = "2018-10-31";
    src = fetchFromGitHub {
      owner = "thestr4ng3r";
      repo = "llvm-dbas";
      rev = "dbfd262d94c6fa77da714a8d2048b296d2ea392a";
      sha256 = "0dmw5r70clvappb3iykh23n9sl6qbbb9bbsl2b1w04ikpvgamnpi";
    };
  };
in with srcinfo;
stdenv.mkDerivation {
  name = "llvm-dbas-${version}";
  inherit src version;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm ];

  meta = with stdenv.lib; {
    description = "LLVM Assembler adding Debug Information at IR Level";
    homepage = https://github.com/thestr4ng3r/llvm-dbas;
    license = licenses.ncsa;
    maintainers = with maintainers; [ dtzWill ];
  };
}
