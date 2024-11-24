# https://github.com/nix-community/nur-combined/blob/master/repos/mic92/pkgs/python-pkgs/deepspeech.nix
{
  lib,
  python39Packages,
  cudaPackages_10_1,
  fetchurl,
  autoPatchelfHook,
  stdenv,
}:
with python39Packages;
let
  pythonVersion = "39";
  version = "0.9.3";
  cudaLibPaths =
    (lib.makeLibraryPath [
      cudaPackages_10_1.cudatoolkit.lib
      cudaPackages_10_1.cudatoolkit.out
      cudaPackages_10_1.cudnn_7_6
    ])
    + ":/run/opengl-driver/lib";
in
buildPythonPackage rec {
  pname = "deepspeech-gpu";
  inherit version;
  wheelName = "deepspeech_gpu-${version}-cp${pythonVersion}-cp${pythonVersion}-manylinux1_x86_64.whl";

  src = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/${wheelName}";
    hash = "sha256-YGvD5Ts4uagjwzJt56yyAOPoz2brAk0gCe+TV7sv6+M=";
  };

  dontUnpack = true;
  format = "other";

  buildInputs = [ stdenv.cc.cc ];
  nativeBuildInputs = [
    pip
    autoPatchelfHook
  ];
  propagatedBuildInputs = [ numpy ];

  installPhase = ''
    runHook preInstall

    cp $src ${wheelName}
    pip install --prefix=$out ${wheelName}

    runHook postInstall
  '';

  makeWrapperArgs = [ "--prefix LD_LIBRARY_PATH : ${cudaLibPaths}" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers";
    homepage = "https://github.com/mozilla/DeepSpeech";
    license = lib.licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    broken = true;
  };
}
