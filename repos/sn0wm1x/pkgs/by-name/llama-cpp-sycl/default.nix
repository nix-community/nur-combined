{ lib, callPackage, llama-cpp, mkl }:
let intel-oneapi-dpcpp-cpp = callPackage ../intel-oneapi-dpcpp-cpp { };
in llama-cpp.overrideAttrs (old: {
  pname = "llama-cpp-sycl";

  buildInputs = old.buildInputs ++ [
    intel-oneapi-dpcpp-cpp
    mkl
  ];

  cmakeFlags = old.cmakeFlags ++ (with lib; [
    (cmakeBool "GGML_SYCL" true)
    (cmakeFeature "CMAKE_C_COMPILER" "${lib.getBin intel-oneapi-dpcpp-cpp}/bin/icx")
    (cmakeFeature "CMAKE_CXX_COMPILER" "${lib.getBin intel-oneapi-dpcpp-cpp}/bin/icpx")
  ]);

  meta = old.meta // {
    broken = true; # WIP
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
  };
})
