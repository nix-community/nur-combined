{ mkDerivation, lib, qtbase, fetchFromGitHub, nasm, gdb, gcc_multi, gcc }:
mkDerivation rec{
  pname = "sasm";
  version = "3.12.1";

  src = fetchFromGitHub {
    owner = "Dman95";
    repo = "SASM";
    rev = "v${version}";
    sha256 = "sha256-BOWnE/AUkug6ZCI1XQPqYAa42RKmPa1XXUb/BPW3QAQ=";
  };

  preConfigure = "qmake PREFIX=$out";

  qtWrapperArgs = [ ''--prefix PATH : ${lib.makeBinPath [nasm gdb gcc]}'' ];

  meta = {
    description = "Simple crossplatform IDE for NASM, MASM, GAS and FASM assembly languages";
    homepage = "https://dman95.github.io/sasm";
    license = lib.licenses.gpl3;
  };
}
