/*
FIXME
/build/source/libethcore/Farm.cpp:373: error: 'class boost::asio::io_context::strand' has no member named 'get_io_service'
  373 |     m_io_strand.get_io_service().post(m_io_strand.wrap(boost::bind(&Farm::restart, this)));
*/

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  boost,
  jsoncpp,
  ethash,
  cudaPackages,
  openssl,
  opencl-headers,
  ocl-icd,
  cli11,
}:

let
  # https://github.com/ethereum/cable
  cable-src = fetchFromGitHub {
    owner = "ethereum";
    repo = "cable";
    # no: cable_set_build_type() must be used before project()
    #rev = "v0.5.0";
    rev = "v0.2.18";
    hash = "sha256-Tw6tlnJYDfrrv/4eLJDCKhsojdKmgFm2kc56taSRfts="; # ok
  };
in

stdenv.mkDerivation rec {
  pname = "progminer";
  #version = "1.1.2";
  version = "unstable-2022-04-14-broken";

  src = fetchFromGitHub {
    owner = "hyle-team";
    repo = "progminer";
    #rev = "v${version}";
    #hash = "sha256-LiURB6l0dVfqMxHQdw0NAOeyPk50SKd7S/rAhjBxoxI=";
    # fix: libethcore/EthashAux.cpp:21:10: fatal error: ethash/progpow.hpp: No such file or directory
    rev = "978b389c2a374b2ccd7b0bc3e5a1a81b0622d78d";
    hash = "sha256-Gc4vPj4lq/UJx78g+QPrXWlXMPEIgdoUUswxf0Wu4gY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    jsoncpp
    ethash
    openssl
    opencl-headers
    ocl-icd
    cli11
    cudaPackages.cudatoolkit # libcudart.so
  ];

  cmakeFlags = [
    # dont use the hunter C++ package manager
    # https://github.com/NixOS/nixpkgs/issues/27431
    "-DHUNTER_ENABLED=OFF"

    #"-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_BUILD_TYPE=Debug"
  ];

  postPatch = ''
    # cuda is required for the cmake target ethash-cuda
    # link to libcudart.so not libcuda.so
    # fix: Could not find CUDA_cuda_LIBRARY using the following names: cuda
    # https://stackoverflow.com/questions/27018340/cmake-does-not-properly-find-cuda-library
    # https://github.com/hyle-team/progminer/pull/2
    substituteInPlace libethash-cuda/CMakeLists.txt \
      --replace-fail \
        'find_library(CUDA_cuda_LIBRARY NAMES cuda PATHS' \
        'find_library(CUDA_cuda_LIBRARY REQUIRED NAMES cudart PATHS' \
      --replace-fail \
        $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_35,code=sm_35")' \
        "$(
          #echo $'\tmessage(FATAL_ERROR "branch 2 COMPUTE=''${COMPUTE}")' # ok
          # no. none of these work. problem: adding too many CUDA_NVCC_FLAGS
          # fix: nvcc fatal   : Unsupported gpu architecture 'compute_30'
          #echo $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_30,code=sm_30")'
          echo $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_75,code=sm_75")'
          #echo $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_80,code=sm_80")'
          #echo $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_86,code=sm_86")'

          echo $'\tlist(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_35,code=sm_35")'
        )" \
      --replace-fail \
        'if(COMPUTE AND (COMPUTE GREATER 0))' \
        "$(
          # fix: nvcc fatal   : Unsupported gpu architecture 'compute_30'
          #echo 'if(COMPUTE AND (COMPUTE GREATER 0))'
          echo 'if(true)'
          #echo $'\tmessage(FATAL_ERROR "branch 1 COMPUTE=''${COMPUTE}")' # ok
          #echo $'\tset(COMPUTE 30)' # no
          # https://github.com/leggedrobotics/darknet_ros/issues/363#issuecomment-991019477
          #echo $'\tset(COMPUTE 75)' # ok
          # https://stackoverflow.com/a/64774956/10440128
          #echo $'\tset(COMPUTE 50)' # ok
          # https://stackoverflow.com/a/65695446/10440128
          echo $'\tset(COMPUTE 80)' # ok
        )" \

    # fix: #warning "The minimum language standard to use Boost.Math will be C++14 starting in July 2023 (Boost 1.82 release)"
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'cable_configure_toolchain(DEFAULT cxx11)' \
        'cable_configure_toolchain(DEFAULT cxx14)' \

    # fix: Could not find toolchain file: toolchains/cxx14.cmake
    rm -rf cmake/cable
    ln -s ${cable-src} cmake/cable

    # fix: #pragma message: The practice of declaring the Bind placeholders (_1, _2, ...) in the global namespace is deprecated.
    # Please use <boost/bind/bind.hpp> + using namespace boost::placeholders,
    # or define BOOST_BIND_GLOBAL_PLACEHOLDERS to retain the current behavior.
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'function(configureProject)' \
        "$(
          echo 'function(configureProject)'
          echo $'\tadd_definitions(-DBOOST_BIND_GLOBAL_PLACEHOLDERS)'
        )" \

    # fix: error: '_1' was not declared in this scope
    substituteInPlace \
      libpoolprotocols/getwork/EthGetworkClient.cpp \
      libpoolprotocols/stratum/EthStratumClient.cpp \
      --replace-fail \
        ', this, _1)));' \
        ', this, std::placeholders::_1)));' \

    # fix: libdevcore/vector_ref.h:152:20: error: 'uint8_t' was not declared in this scope
    substituteInPlace \
      libdevcore/vector_ref.h \
      --replace-fail \
        '#include <vector>' \
        "$(
          echo '#include <vector>'
          echo '#include <cstdint>'
        )" \

  '';

  meta = {
    description = "ProgPoWZ 0.9.2 miner with OpenCL, CUDA, CPU and stratum support (Zano version";
    homepage = "https://github.com/hyle-team/progminer";
    changelog = "https://github.com/hyle-team/progminer/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "progminer";
    platforms = lib.platforms.all;
  };
}
