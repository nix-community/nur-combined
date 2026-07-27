{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, cmake
, ninja
, pkg-config
, cudaPackages ? { }
, glew-egl
, python
, pybind11
, torch
, tensorflow
, numpy
, imageio
}:

with cudaPackages;

let
  pname = "nvdiffrast";
  version = "0.3.1";
in
buildPythonPackage rec {
  inherit pname version;
  format = "other";

  src = fetchFromGitHub {
    owner = "NVLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CUni9pRUNyX3erquNYSFOGVKCzK46Pj6n8lkWdIeWqI=";
  };
  patches = [
    (fetchurl {
      url = "https://github.com/SomeoneSerge/nvdiffrast/pull/1/commits/e3632fa405d1f31911d2be7b07377392c89f2648.patch";
      hash = "sha256-OoKar6bCDurRO4g2C7jOd8oFKFFTrHy4D/Gct4OjLzs=";
    })
  ];
  postPatch = ''
    substituteInPlace samples/torch/*.py \
      --replace \
        'import util' \
        'import nvdiffrast.samples.torch.util as util'
  '';


  nativeBuildInputs = [
    cuda_nvcc
    cmake
    pkg-config
  ];
  buildInputs = [
    (lib.getDev cuda_nvcc)
    cuda_cudart # CUDA_CUDART_LIBRARY
    cuda_cccl.dev # CUDA_CUDART_LIBRARY
    cudnn
    cuda_nvrtc # CUDA_NVRTC_LIB
    cuda_nvtx # LIBNVTOOLSEXT
    libcusparse # cusparse.h
    libcublas # cublas_v2.h
    libcusolver # cusolverDn.h
    libcurand # CUDA_curand_LIBRARY
    libcufft # -lCUDA_cufft_LIBRARY-NOTFOUND

    pybind11
    torch.dev

    glew-egl.dev # EGL/egl.h
  ];
  propagatedBuildInputs = [
    numpy
  ];

  cmakeFlags = [
    "-DPython_SITEARCH=${placeholder "out"}/${python.sitePackages}"
    "-DPython_SITELIB=${placeholder "out"}/${python.sitePackages}"
    "-DTORCH_CUDA_ARCH_LIST=${builtins.concatStringsSep ";" cudaPackages.cudaFlags.cudaCapabilities}"
  ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;

  checkInputs = [
    torch
  ];
  pythonImportsCheck = [
    "nvdiffrast.torch"
  ];

  passthru.extras-require.all = [
    imageio
    ninja
  ]
  # cpp_extension wants ninja and nvcc:
  ++ buildInputs;

  postFixup = ''
    cp -r ../samples "$out/${python.sitePackages}/nvdiffrast/"
  '';

  passthru.tests.withTensorflow = nvdiffrast.overridePythonAttrs (a: {
    checkInputs = a.checkInputs ++ [
      tensorflow
    ];
    pythonImportsCheck = a.pythonImportsCheck ++ [
      "nvdiffrast"
    ];
  });
  passthru.gpuTests = callPackage ./gpu-tests.nix { };

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = {
      fullName = "Nvidia Source Code License (1-Way Commercial)";
      free = true;
    };
    description = "Modular Primitives for High-Performance Differentiable Rendering";
    homepage = "https://nvlabs.github.io/nvdiffrast/";
    platforms = lib.platforms.unix;
  };
}
