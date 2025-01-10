{ lib, stdenv, fetchFromGitHub }:

let
  cc = "${stdenv.cc.targetPrefix}cc";
  cxx = "${stdenv.cc.targetPrefix}c++";
  ar = "${stdenv.cc.targetPrefix}ar";
in
stdenv.mkDerivation rec {
  pname = "ctrtool";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "ctrtool-v${version}";
    sha256 = "sha256-HqqeQCEUof4EBUhuUAdTruMFgYIoXhtAN3yuWW6tD+Y=";
  };

  postPatch = ''
    # because substituteInPlace is a shell function, we can't use find -exec
    for f in $(find ctrtool -name "makefile"); do
      substituteInPlace $f \
        --replace-fail @ar ${ar} \
        --replace-fail @gcc ${cc}
    done

    # goddamn case sensitivity
    substituteInPlace ctrtool/deps/libtoolchain/include/tc/io/MemoryStream.h \
      --replace-warn Windows.h windows.h
    substituteInPlace ctrtool/deps/libtoolchain/include/tc/io/FileStream.h \
      --replace-warn Windows.h windows.h
  '';

  preBuild = ''
    cd ctrtool
    make SHELL=${stdenv.shell} -j$NIX_BUILD_CORES deps CC=${cc} CXX=${cxx} ${lib.optionalString stdenv.targetPlatform.isWindows "ARCHFLAGS=-municode"}
  '';

  makeFlags = [ "CC=${cc}" "CXX=${cxx}" ] ++ (lib.optional stdenv.targetPlatform.isWindows "ARCHFLAGS=-municode");
  enableParallelBuilding = true;

  installPhase = ''
    mkdir $out/bin -p
    cp bin/ctrtool${stdenv.targetPlatform.extensions.executable} $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "A tool to extract data from a 3ds rom";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    platforms = platforms.all;
    mainProgram = "ctrtool";
  };

}
