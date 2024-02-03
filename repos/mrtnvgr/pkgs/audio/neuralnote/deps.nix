{ fetchurl }:
[
  {
    name = "abseil_cpp";
    sha1 = "50c137c88965cba015dfcc8fd5d9b46d23146751";
    file = fetchurl {
      url =
        "https://github.com/abseil/abseil-cpp/archive/refs/tags/20220623.1.zip";
      sha256 = "sha256-VHB/QRy2KiandtrV/WCCkJjBgXAO3NAi6lwspJ6bfvE=";
    };
  }
  {
    name = "cxxopts";
    sha1 = "6c6ca7f8480b26c8d00476e0e24b7184717fe4f0";
    file = fetchurl {
      url =
        "https://github.com/jarro2783/cxxopts/archive/3c73d91c0b04e2b59462f0a741be8c07024c1bc0.zip";
      sha256 = "sha256-V7XwEjctTA4Kl1suU06a9kfNIFMPxy9zp1ph4F4PmX4=";
    };
  }
  {
    name = "date";
    sha1 = "ea99f021262b1d804a872735c658860a6a13cc98";
    file = fetchurl {
      url =
        "https://github.com/HowardHinnant/date/archive/refs/tags/v2.4.1.zip";
      sha256 = "sha256-knjXVor99vuIDyd9XjRPksBTFFnxVkO8lFhJwvIJ2rI=";
    };
  }
  {
    name = "dlpack";
    sha1 = "4d565dd2e5b31321e5549591d78aa7f377173445";
    file = fetchurl {
      url = "https://github.com/dmlc/dlpack/archive/refs/tags/v0.6.zip";
      sha256 = "sha256-yylrJfGtXVKqDv11U+GqsXq0Vh0QaLKR++FNVD0i84E=";
    };
  }
  {
    name = "flatbuffers";
    sha1 = "ba0a75fd12dbef8f6557a74e611b7a3d0c5fe7bf";
    file = fetchurl {
      url =
        "https://github.com/google/flatbuffers/archive/refs/tags/v1.12.0.zip";
      sha256 = "sha256-S4shrb/op0uQYEFhr8+HwSWia4bJkyfnoEUlCAYGU2w=";
    };
  }
  {
    name = "fp16";
    sha1 = "b985f6985a05a1c03ff1bb71190f66d8f98a1494";
    file = fetchurl {
      url =
        "https://github.com/Maratyszcza/FP16/archive/0a92994d729ff76a58f692d3028ca1b64b145d91.zip";
      sha256 = "sha256-5m5lUV+gmSezSNPVhMaL5CFc/mZBANAcnbx2VaVxbXA=";
    };
  }
  {
    name = "fxdiv";
    sha1 = "a5658f4036402dbca7cebee32be57fb8149811e1";
    file = fetchurl {
      url =
        "https://github.com/Maratyszcza/FXdiv/archive/63058eff77e11aa15bf531df5dd34395ec3017c8.zip";
      sha256 = "sha256-PXsOnExlioQ3ahCGEmvgL5t/dTyqleAJ2aw40R2kRNs=";
    };
  }
  {
    name = "google_benchmark";
    sha1 = "e97c368b176e8614e3f1bf13dd9abcf6a7ad9908";
    file = fetchurl {
      url = "https://github.com/google/benchmark/archive/refs/tags/v1.7.0.zip";
      sha256 = "sha256-4Oag8qXolxGY5dOCUHv+jkvlBHl9dbt67ES16jaPoQA=";
    };
  }
  {
    name = "google_nsync";
    sha1 = "f3233450cf7156fc0bedd1b0e884eddec264897c";
    file = fetchurl {
      url = "https://github.com/google/nsync/archive/refs/tags/1.23.0.zip";
      sha256 = "sha256-8HmLSrVwVkHA+NPcf+7QRRtMfClPI+vUQ5B5ohIEXWc=";
    };
  }
  {
    name = "googletest";
    sha1 = "4b3c37972e4c1bef1185d46f702082f8772ee73f";
    file = fetchurl {
      url =
        "https://github.com/google/googletest/archive/519beb0e52c842729b4b53731d27c0e0c32ab4a2.zip";
      sha256 = "sha256-VK5PVzDYqnw2poT/3CihVcQZEPCFOsQk7NMVd3iCm6M=";
    };
  }
  {
    name = "googlexnnpack";
    sha1 = "9f192e3f15e1e37ae9c78d53eeea47e45c5eb31c";
    file = fetchurl {
      url =
        "https://github.com/google/XNNPACK/archive/003c580e696a774afdc984996ee909b7c8d8128c.zip";
      sha256 = "sha256-MvrckdnX1iQiOzxAkbZlCdMhXR/2pH7whswICbSXiyA=";
    };
  }
  {
    name = "json";
    sha1 = "f257f8dc27c5b8c085dc887b40cddd18ae1f725c";
    file = fetchurl {
      url = "https://github.com/nlohmann/json/archive/refs/tags/v3.10.5.zip";
      sha256 = "sha256-6ksAhHCfuTT5LKCmhmnaoP5vKixkAL81NFSZOoNLsLs=";
    };
  }
  {
    name = "microsoft_gsl";
    sha1 = "cf368104cd22a87b4dd0c80228919bb2df3e2a14";
    file = fetchurl {
      url = "https://github.com/microsoft/GSL/archive/refs/tags/v4.0.0.zip";
      sha256 = "sha256-65H8sQpqpcyx0iTgelbI7P/pobtgH6GEgnbsRqIgC/s=";
    };
  }
  {
    name = "microsoft_wil";
    sha1 = "fd119887d0d17c37adf1fc227b054befa28158ad";
    file = fetchurl {
      url =
        "https://github.com/microsoft/wil/archive/5f4caba4e7a9017816e47becdd918fcc872039ba.zip";
      sha256 = "sha256-5hk8wpENZs6U43OtN9YL9DSkAUTjbNkeLE/HX7AYluc=";
    };
  }
  {
    name = "mimalloc";
    sha1 = "e4f37b93b2da78a5816c2495603a4188d316214b";
    file = fetchurl {
      url =
        "https://github.com/microsoft/mimalloc/archive/refs/tags/v2.0.3.zip";
      sha256 = "sha256-jl8LdP2vqwnohTQVcAqa3k1i1fVs1D9UrfAlgM7ahsE=";
    };
  }
  {
    name = "mp11";
    sha1 = "c8f04e378535ededbe5af52c8f969d2dedbe73d5";
    file = fetchurl {
      url =
        "https://github.com/boostorg/mp11/archive/refs/tags/boost-1.79.0.zip";
      sha256 = "sha256-7QT12LMMrX/BbQ5Mn2cMbfELAYRTFfrWlgFcTl5enMg=";
    };
  }
  {
    name = "onnx";
    sha1 = "8dda5079cdb5a134b08b0c73f4592a6404fc2dc6";
    file = fetchurl {
      url = "https://github.com/onnx/onnx/archive/refs/tags/v1.13.0.zip";
      sha256 = "sha256-57yaRM6RlT4V9WCQw987I4ppK/boHZPv0T8b/uPYAaE=";
    };
  }
  {
    name = "onnx_tensorrt";
    sha1 = "62119892edfb78689061790140c439b111491275";
    file = fetchurl {
      url =
        "https://github.com/onnx/onnx-tensorrt/archive/369d6676423c2a6dbf4a5665c4b5010240d99d3c.zip";
      sha256 = "sha256-AD8rEbhjDs+JzrBLyWOof0VQZ3lC7PkPBZiRmTwUq7g=";
    };
  }
  {
    name = "protobuf";
    sha1 = "9f71dad95fb83438e88822a9969fc93773fd8c48";
    file = fetchurl {
      url =
        "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.20.2.zip";
      sha256 = "sha256-1WIDDZk0UebK/oSioGO6wzo0vGUpEflnnBlrKbHRZNk=";
    };
  }
  {
    name = "psimd";
    sha1 = "1f5454b01f06f9656b77e4a5e2e31d7422487013";
    file = fetchurl {
      url =
        "https://github.com/Maratyszcza/psimd/archive/072586a71b55b7f8c584153d223e95687148a900.zip";
      sha256 = "sha256-3GFTQry+UcqIUyPlG2i5Dtm7n6ffD0QZ2/oCl9XoN7c=";
    };
  }
  {
    name = "pthreadpool";
    sha1 = "e43e80781560c5ab404a4da20f34d846f5f5d101";
    file = fetchurl {
      url =
        "https://github.com/Maratyszcza/pthreadpool/archive/1787867f6183f056420e532eec640cba25efafea.zip";
      sha256 = "sha256-7EfUArQ612Oyozcn8kWRRDl+jE8fT66bBkV2JAxWJVc=";
    };
  }
  {
    name = "pybind11";
    sha1 = "769b6aa67a77f17a770960f604b727645b6f6a13";
    file = fetchurl {
      url = "https://github.com/pybind/pybind11/archive/refs/tags/v2.10.1.zip";
      sha256 = "sha256-/PlAZe/P0KeoKLrPEY+hHEP2OQ0MgF4+Y0KsEZ8umXY=";
    };
  }
  {
    name = "pytorch_cpuinfo";
    sha1 = "2be4d2ae321fada97cb39eaf4eeba5f8c85597cf";
    file = fetchurl {
      url =
        "https://github.com/pytorch/cpuinfo/archive/5916273f79a21551890fd3d56fc5375a78d1598d.zip";
      sha256 = "sha256-KhYMUn08WAhc4mDzT54rFhrcAJs0GGorryTnQ3bonm0=";
    };
  }
  {
    name = "re2";
    sha1 = "aa77313b76e91b531ee7f3e45f004c6a502a5374";
    file = fetchurl {
      url = "https://github.com/google/re2/archive/refs/tags/2022-06-01.zip";
      sha256 = "sha256-nztl8uDHglP8/fzhdUFysPl//bZD7l/WfwGFrPkaPyg=";
    };
  }
  {
    name = "safeint";
    sha1 = "913a4046e5274d329af2806cb53194f617d8c0ab";
    file = fetchurl {
      url =
        "https://github.com/dcleblanc/SafeInt/archive/ff15c6ada150a5018c5ef2172401cb4529eac9c0.zip";
      sha256 = "sha256-9cUPNa7WPJ3auQy3S+MeLvDZN3RS3wJlVG6Kiv59Xy8=";
    };
  }
  {
    name = "tensorboard";
    sha1 = "67b833913605a4f3f499894ab11528a702c2b381";
    file = fetchurl {
      url =
        "https://github.com/tensorflow/tensorboard/archive/373eb09e4c5d2b3cc2493f0949dc4be6b6a45e81.zip";
      sha256 = "sha256-x8d7MOcFbcd8Bn7HD84k6AqSdSK5c+vvrDOIi6GLWn0=";
    };
  }
  {
    name = "cutlass";
    sha1 = "be70c559f07251ba7f33c789dba98872b444c10f";
    file = fetchurl {
      url = "https://github.com/NVIDIA/cutlass/archive/refs/tags/v2.11.0.zip";
      sha256 = "sha256-EBXlKCAu7Tr/4/kP7WZri1dnmWq9szZ+dlEK1nF5su0=";
    };
  }
  {
    name = "openssl";
    sha1 = "dda8fc81308555410505eb4a9eab3e1da0436a1d";
    file = fetchurl {
      url =
        "https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.7.zip";
      sha256 = "sha256-/LNyA8a/c3bP066wvgV5N7dhHpmLbA1mSr3pKMivPrc=";
    };
  }
  {
    name = "rapidjson";
    sha1 = "0fe7b4f7b83df4b3d517f4a202f3a383af7a0818";
    file = fetchurl {
      url = "https://github.com/Tencent/rapidjson/archive/refs/tags/v1.1.0.zip";
      sha256 = "sha256-jgDDiCnWeFot+5UbuHxpdPoH3+SIqlsl3uxLi8D2o6s=";
    };
  }
  {
    name = "boost";
    sha1 = "f6ab0da855f825b4eb1abd949967d01a4c5e4e1b";
    file = fetchurl {
      url =
        "https://github.com/boostorg/boost/archive/refs/tags/boost-1.81.0.zip";
      sha256 = "sha256-F7hOVojd/LHyESum1uolZGjuq5IY9YQ0S28pdQboR7M=";
    };
  }
  {
    name = "b64";
    sha1 = "815b6d31d50d9e63df55b25ce555e7b787153c28";
    file = fetchurl {
      url = "https://github.com/libb64/libb64/archive/refs/tags/v2.0.0.1.zip";
      sha256 = "sha256-DD09N6AleF77t+qVqnlgxmbG9H5wJwxFcizx5r4uv4Y=";
    };
  }
  {
    name = "pthread";
    sha1 = "3b9e417e4474c34542b76ad40529e396ac109fb4";
    file = fetchurl {
      url =
        "https://sourceforge.net/projects/pthreads4w/files/pthreads4w-code-v3.0.0.zip";
      sha256 = "sha256-uBE27/txhcd2Af4uDmrBm9mWkS5IFM690wELD6yeJZs=";
    };
  }
  {
    name = "triton";
    sha1 = "4b305570aa1e889946e20e36050b6770e4108fee";
    file = fetchurl {
      url =
        "https://github.com/triton-inference-server/server/archive/refs/tags/v2.28.0.zip";
      sha256 = "sha256-3dqPf2pRU0CV7uWiN92yLFlDJ1LD1nv3zJWBJgQVKG0=";
    };
  }
]
