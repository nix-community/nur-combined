{
  stdenv,
  callPackage,
  lib,
  fetchFromGitLab,
  lz4,
  opencv,
  ffmpeg,
  llvmPackages,
}:

let
  realOpencv =
    if stdenv.isDarwin && stdenv.hostPlatform.isStatic then
      opencv.override {
        ffmpeg = ffmpeg.override {
          withSdl2 = false;
        };
      }
    else
      opencv;
in
stdenv.mkDerivation rec {
  pname = "makebax";
  version = "2019-01-22";

  src = fetchFromGitLab {
    repo = "BAX";
    owner = "Wolfvak";
    rev = "e8c7e79757747be4352f85334334e018ae1a2dea";
    hash = "sha256-ClkSlatx9bC14KyRg+CF1GjkBJ1qpeWyIVUwO+Pd1Y0=";
  };
  sourceRoot = "${src.name}/makebax";

  patches = [
    ./fix-bad-alloc.patch
    ./fix-array.patch
  ];

  NIX_CFLAGS_COMPILE = "-isystem ${realOpencv}/include/opencv4";

  buildInputs = [
    lz4
    realOpencv
  ]
  ++ (lib.optional stdenv.cc.isClang llvmPackages.openmp);

  installPhase = ''
    mkdir -p $out/bin
    cp makebax $out/bin
  '';

  meta = with lib; {
    description = "BAX Animation creator";
    homepage = "https://gitlab.com/Wolfvak/BAX";
    license = licenses.mit;
    platforms = platforms.all;
    broken = stdenv.isDarwin && stdenv.hostPlatform.isStatic;
    mainProgram = "makebax";
  };
}
