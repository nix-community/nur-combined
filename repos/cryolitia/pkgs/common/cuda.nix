{ cudaPackages
, symlinkJoin
}:

rec {
  cuda-common-redist = with cudaPackages; [
    cuda_cccl # cub/cub.cuh
    libcublas # cublas_v2.h
    libcurand # curand.h
    libcusparse # cusparse.h
    libcufft # cufft.h
    cudnn # cudnn.h
  ];

  cuda-native-redist = symlinkJoin {
    name = "cuda-native-redist-${cudaPackages.cudaVersion}";
    paths = with cudaPackages; [
      cuda_cudart # cuda_runtime.h cuda_runtime_api.h
      cuda_nvcc
    ] ++ cuda-common-redist;
  };

  cuda-redist = symlinkJoin {
    name = "cuda-redist-${cudaPackages.cudaVersion}";
    paths = cuda-common-redist;
  };
}
