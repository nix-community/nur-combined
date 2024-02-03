{ 
lib
, stdenv
, fetchFromGitHub
, cmake
, bin2c
, python3
, callPackage
, git
, fetchurl
}:
let
  deps-file = callPackage ./nix_deps.nix { };
  eigen-dep = fetchurl {
    url =
      "https://gitlab.com/libeigen/eigen/-/archive/d10b27fe37736d2944630ecd7557cefa95cf87c9/eigen-d10b27fe37736d2944630ecd7557cefa95cf87c9.zip";
    sha256 = "sha256-+xhSeekMZRz9MSnLAwUvyVAgopoTqusWXCi27amMtTA=";
  };
in
stdenv.mkDerivation rec {
  pname = "libonnxruntime-neuralnote";
  version = "1ac0228d5d07890c0a504fbdeb6588e00afe1b8a";

  src = fetchFromGitHub {
    owner = "polygon";
    repo = "libonnxruntime-neuralnote";
    rev = "${version}";
    sha256 = "sha256-3u/iHDimvKgKY3yamFAi0HutWeqFHtjGRYUE7ljFpyQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [
      flatbuffers
      onnxruntime
      onnx
    ]))
    git
    cmake
    bin2c
  ];

  dontConfigure = true;
  dontStrip = true;

  patchPhase = ''
    cp ${deps-file} onnxruntime/cmake/deps.txt
    sed -i -e 's#https://gitlab.com/libeigen/eigen/-/archive/d10b27fe37736d2944630ecd7557cefa95cf87c9/eigen-d10b27fe37736d2944630ecd7557cefa95cf87c9.zip#${eigen-dep}#' onnxruntime/cmake/external/eigen.cmake
    sed -i -e '/--parallel/a\' -e '--skip_submodule_sync \\' build-linux.sh
  '';

  buildPhase = ''
    sh convert-model-to-ort.sh model.onnx
    sh build-linux.sh
  '';

  installPhase = ''
    mkdir -p $out
    cp libonnxruntime-neuralnote.tar.gz $out/
  '';
}
