{
  lib,
  stdenv,
  cmake,
  clang,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "darctool";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "dnasdw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ZiIohUam7PoNzRI/m4q4KLBdEbAJcJMatyFPnObXMq0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];
  cmakeFlags = [
    (lib.cmakeFeature "USE_DEP" "OFF")
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];
  enableParallelBuilding = true;

  # fixes building on linux aarch64 (or anything non-x86_64 probably)
  postPatch = ''
    sed -i 's/-m64//g' CMakeLists.txt
    sed -i 's/-m32//g' CMakeLists.txt

    # god damn case sensitivity
    substituteInPlace dep/libsundaowen/sdw_type.h \
      --replace-fail Windows.h windows.h
  '';

  installPhase = "
    mkdir $out/bin -p
    cp ../bin/Release/darctool${stdenv.hostPlatform.extensions.executable} $out/bin/
    cp ../bin/ignore_darctool.txt $out/bin/
  ";

  meta = with lib; {
    description = "A tool for extracting/creating darc file.";
    homepage = "https://github.com/dnasdw/darctool";
    platforms = platforms.all;
    mainProgram = "darctool";
  };
}
