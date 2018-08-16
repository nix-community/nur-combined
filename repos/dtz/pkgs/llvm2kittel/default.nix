{ stdenv, cmake, llvm, gmp, git, fetchgit }:

stdenv.mkDerivation rec {
  name = "llvm2kittel-${version}";
  version = "2017-02-16";

  src = fetchgit {
    url = "http://github.com/s-falke/llvm2kittel.git";
    rev = "ec8e9d58621551af39ca0426c8d3b57f44f71775";
    sha256 = "0pd0gpg1w63ssx31qrd8xjcv2rhxb6a0qcsh70kmm8m0bs7ndr9i";
    leaveDotGit = true;
  };

  buildInputs = [ cmake llvm gmp git ];

  patchPhase = ''
    patchShebangs make_git_sha1.sh

    substituteInPlace CMakeLists.txt --replace \
      ' ''${LLVM_SYSTEM_LIBS}' ""
  '';

  installPhase = "install -Dm755 {,$out/bin/}llvm2kittel";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "llvm2KITTeL";
    homepage = https://github.com/s-falke/llvm2kittel;
    license = licenses.ncsa;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
