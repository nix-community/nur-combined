{ lib
, stdenv
, python3
, ffmpeg
, fetchFromGitHub
, cmake
, pkg-config
}:

python3.pkgs.buildPythonApplication rec {
  pname = "decord";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dmlc";
    repo = "decord";
    #rev = "v${version}";
    # https://github.com/dmlc/decord/pull/301
    # fix build for ffmpeg6
    rev = "38f59c34799071a20076a1d16e9ea400fa40595a";
    hash = "sha256-5aOZnq0VvWjeD6rOeu+cCiF22G4J4OJie0J5UXtvsTI=";
    fetchSubmodules = true;
  };

  passthru = {
    inherit libdecord;
  };

  libdecord = stdenv.mkDerivation rec {
    pname = "libdecord";
    inherit src version;
    # you can specify -DUSE_CUDA=ON or -DUSE_CUDA=/path/to/cuda
    # or -DUSE_CUDA=ON -DCMAKE_CUDA_COMPILER=/path/to/cuda/nvcc
    # to enable NVDEC hardware accelerated decoding
    #cmakeFlags = [
    #  "-DUSE_CUDA=OFF"
    #];
    nativeBuildInputs = [
      cmake
      pkg-config
    ];
    buildInputs = [
      ffmpeg
    ];
    # TODO remove?
    installPhase = ''
      mkdir -p $out/lib
      cp libdecord.so $out/lib
    '';
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  preBuild = ''
    mkdir build
    cp $libdecord/lib/libdecord.so build
    cd python
  '';

  checkInputs = with python3.pkgs; [
    mxnet
  ];

  # checks require GPU
  doCheck = false;

  propagatedBuildInputs = with python3.pkgs; [
    numpy
  ];

  pythonImportsCheck = [ "decord" ];

  meta = with lib; {
    description = "efficient video loader for deep learning with fast random access";
    homepage = "https://github.com/dmlc/decord";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
