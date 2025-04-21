{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  vulkan ? true, vulkan-loader, vulkan-headers, shaderc, glslang,
  hipblas ? false, rocmPackages, buildEnv,
  hipblasTarget ? "gfx1030"
}:

stdenv.mkDerivation rec {
  pname = "stable-diffusion-cpp";
  version = "10feacf";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "master-${version}";
    hash = "sha256-LrWS16rddPqJJc+73/6mNqWdweAd0ZboxI5m1rvIxtA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake git
  ]
  ++ lib.optionals vulkan [ 
      vulkan-headers shaderc glslang
  ]
  ++ lib.optionals hipblas [
    rocmPackages.llvm.clang
    rocmPackages.hipblas
  ];

  buildInputs = lib.optionals vulkan [
    vulkan-loader
  ];

  cmakeFlags = lib.optionals vulkan [
    "-DSD_VULKAN=ON"
  ]
  ++ lib.optionals hipblas [
    "-DSD_HIPBLAS=ON"
    "-DAMDGPU_TARGETS=${hipblasTarget}"
    "-DCMAKE_C_COMPILER=clang"
    "-DCMAKE_CXX_COMPILER=clang++"
  ];

  rocmPath = buildEnv {
    name = "rocm-path";
    paths = with rocmPackages; [
      clr hipblas rocblas rocm-device-libs
      rocm-comgr rocm-runtime
    ];
  };

  env = lib.optionalAttrs hipblas
    {
      ROCM_PATH = rocmPath;
    };

  meta = {
    description = "Stable Diffusion and Flux in pure C/C";
    homepage = "https://github.com/leejet/stable-diffusion.cpp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "stable-diffusion-cpp";
    platforms = lib.platforms.all;
  };
}
