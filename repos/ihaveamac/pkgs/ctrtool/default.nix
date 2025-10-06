{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:

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

  patches = [
    ./libtoolchain-include-limits.patch
    # TMDS > 1024 contents
    (fetchpatch {
      url = "https://github.com/3DSGuy/Project_CTR/commit/bca09927428c35253888efda8eb6e8a2150a6c08.patch";
      hash = "sha256-w2+Gk2LiR20TzK5o6u8YE+lxQp1I+7lJnG2jEMYSzwM=";
    })
    # New 3DS bit
    (fetchpatch {
      url = "https://github.com/3DSGuy/Project_CTR/commit/ba33e8d3238150ad2b7e451a475852dbb4135c95.patch";
      hash = "sha256-Au8TIR6Fp9tGxez52omdU0b64HbDDTkxyXbJHG1pJRY";
    })
  ];

  preBuild = ''
    cd ctrtool
    make SHELL=${stdenv.shell} -j$NIX_BUILD_CORES deps ${lib.escapeShellArgs makeFlags}
  '';

  makeFlags = [
    "CC=${cc}"
    "CXX=${cxx}"
  ]
  ++ (lib.optional stdenv.hostPlatform.isWindows "ARCHFLAGS=-municode");
  enableParallelBuilding = true;

  # workaround for https://github.com/3DSGuy/Project_CTR/issues/145
  # (this doesn't happen with clang though)
  env.NIX_CFLAGS_COMPILE = "-O0";

  installPhase = ''
    mkdir $out/bin -p
    cp bin/ctrtool${stdenv.hostPlatform.extensions.executable} $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "A tool to extract data from a 3ds rom";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    platforms = platforms.all;
    mainProgram = "ctrtool";
  };

}
