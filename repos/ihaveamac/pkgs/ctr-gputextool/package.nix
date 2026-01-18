{
  lib,
  stdenv,
  libiconvReal,
  fetchFromGitHub,
}:

let
  lodepng = fetchFromGitHub {
    owner = "lvandeve";
    repo = "lodepng";
    rev = "344b4b442d0de0787a999724dd6569461a00c92c";
    hash = "sha256-347K9rIJQlhz4g0dzg8Mtl2JUIjUt+SdKLJpqzV5vcI=";
  };
in
stdenv.mkDerivation rec {
  pname = "ctr-gputextool";
  version = "0-unstable-2015-11-25";

  src = fetchFromGitHub {
    owner = "yellows8";
    repo = pname;
    rev = "b7bafb64c11d0736347a748bd3dbf583135f0fbb";
    hash = "sha256-IK5nArZYy+gXdYp6IM3RO+H2eieY9iahmJhMPu+JAv8=";
  };

  passthru.lodepng = lodepng;

  preBuild = ''
    mkdir lodepng
    cp ${lodepng}/lodepng.cpp lodepng/lodepng.c
    cp ${lodepng}/lodepng.h lodepng/lodepng.h
  '';

  buildPhase = ''
    runHook preBuild
    ${stdenv.cc.targetPrefix}cc -o ctr-gputextool ctr-gputextool.c utils.c lodepng/lodepng.c -DLODEPNG_NO_COMPILE_CPP
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ctr-gputextool${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "3DS GPU texture conversion tool.";
    homepage = "https://github.com/yellows8/ctr-gputextool";
    platforms = platforms.all;
    mainProgram = "ctr-gputextool";
  };
}
