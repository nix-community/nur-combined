{ stdenv, fetchFromGitHub, cmake, llvm }:

let
  srcinfo = {
    version = "2018-09-17";
    src = fetchFromGitHub {
      owner = "thestr4ng3r";
      repo = "llvm-dbas";
      rev = "74714e5260810dbb9b49afe2446aae0cf393febb";
      sha256 = "1pri6ylbl6p24l5j3dm3pr10p3z7aayf6qsf7z7dp0kmrcvby66r";
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
