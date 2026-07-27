{ buildPackages
, buildPythonPackage
, cudaPackages
, fetchFromGitHub
, lib
, pybind11
, stdenv
, symlinkJoin
, torch
, which
}:

{ ...
}@args:

buildPythonPackage (args // rec {
  env.TORCH_CUDA_ARCH_LIST = args.TORCH_CUDA_ARCH_LIST or "${lib.concatStringsSep ";" torch.cudaCapabilities}";
  env.CUDA_HOME = args.CUDA_HOME or symlinkJoin {
    name = "cuda-unsplit";
    paths = [
      buildPackages.cudaPackages.cuda_nvcc
      cudaPackages.cuda_cccl
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
      cudaPackages.libcusolver
      cudaPackages.libcusparse
    ];
  };
  nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
    cudaPackages.backendStdenv.cc
    which
  ];
  buildInputs = (args.buildInputs or [ ]) ++ [
    pybind11
  ];
  propagatedBuildInputs = (args.propagatedBuildInputs or [ ]) ++ [
    torch
  ];
  meta = (args.meta or { }) // {
    broken = args.meta.broken or (!torch.cudaSupport);
  };
})
