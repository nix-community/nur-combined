{ stdenv, lit, llvm, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "llvmslicer-${version}";
  version = "2016-09-25";

  src = fetchFromGitHub {
    owner = "sdasgup3";
    repo = "llvm-slicer";
    rev = "a50ba9555155bb830cda6d91c545a406f97d2c30";
    sha256 = "0vcs8bw38ybd94maa1ks44cnc3zfv2gz6b0nfk8pmlgzcn71nwjb";
  };

  doCheck = true;
  enableParallelBuilding = true;

  # Patch around attempt to use bits from LLVM's source tree,
  # instead use the ones shipped with this project already :)
  patchPhase = ''
    sed -i -e 's,{llvm_src}/autoconf/,{srcdir}/autoconf/,g' configure
  '';

  # This is needed when the host compiler doesn't default to C++11.
  configureFlags = "--enable-cxx11";

  buildInputs = [ lit llvm ];

  meta = with stdenv.lib; {
    description = "Static Slicer for LLVM 3.5";
    license = licenses.ncsa;
    homepage = https://github.com/sdasgup3/llvm-slicer;
  };
}
