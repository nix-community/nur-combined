{ fetchurl }: {
  version = "5.5.2";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu/amdgpu_5.5.50502-1607507.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "45c196ce09d1f8a12d8dffb3b30d2308ec251d94bcc213718276e8cdaef1c538";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "7d2f63753b155bdd80ad82c4bfc8da122998604b8f7cc3429aa4d3010721af4f";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "82dd14d419160dd410a93dfbc975f44492eb29c1acb3e93e4b82c2413d23e8a6";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "ba314b92aa54f4b245e0fd0e02c2e18b47340e8bef7fc03959fdc52f27d03705";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "ffc8c59f00dbaa7dbded0c3cca1f484e686d4351bbf8274b9fa027c544d476f2";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1607507.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "1c484a8609cd8598baf7d87bd411724ecf1272d0c2be99fe03221b8d471487a8";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "3e133d1a0113544adb00fb1e7874771ce2e1c963af320ae14dfe150c029b2bcb";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.5.50502-1607507.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "fbfd89925bc0fef5791b01c0ea861cd2755060f8b66e6beefaef2c19bc396ea4";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.5.50502-1607507.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "06845d4bc419558d96a31176dc238b18aa44ded045753b940d61640380bfbd7b";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50502-1607507.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "88b8fff67b28820a9b55e616e6eea813568600f191440238337a34039c34cbf5";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50502-1607507.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "03a09a690c51c85cd0ecb443b7c8757b1477c1f5641fd1432dad7058bfd9cfce";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50502-1607507.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "4b2221ff726fd94d503cbb42be56f261e9c5c60c5fda8cffa9487272a7665c6c";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50502-1607507.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "02e90b45ce999829cb69757cb64b3c0b8ee4854839547d3200f598f78d096da2";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50502-1607507.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "5ea465f696ac4a501fc2ee31828e3d1654c91c9c3804cfc25f1d7cbb359be7a1";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50502-1607507.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "4aa57730dc94485f65b21d7f72aedd888045d055275b160bb1def31478d2eeee";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50502-1607507.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "3c49d7718c67ed06911a27c42c1a65c200e887760cd6183b4eccb783df915da3";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "0ab509da153612060fd856ddacef9b29348d50038f771188e1f76c9c8892c09b";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "1c1276d0e3a290ea9b4a82550e345ebd3af931b8cd19aad8cd859ad7f2a0d91e";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "7a0e6a14a620dc24680c0d7569e12e2aed754a2784d53bd397afd1965c4d6ae8";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "1915239eee0a91d8b129719fd46db6140c3759f0033d7992e188410e4051fa80";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "b2231c66e9a9469036f6002b091c1fa025e0ecd9e87da2bacf96878e9405aa8a";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "7cb4f84da74b2ba77114543a9dd9944960d69e651cce7db1c9fbbbc23c85e765";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "94a39c3d0f7166503ed159792b1368f1fbd155fbfe732f56f95e238e2f7bf89c";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "b529f8309730616af4f9c5cfa032056eb9c83313a27ecbf634f1d46d85b2d9d8";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "65af1314e0e6f2e4e6c2f28278eb2810fe558daf305d04cad30be5488b1ee049";
    });

    libllvm15_0_50502-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50502-amdgpu_15.0.50502-1607507.22.04_amd64.deb";
      name = "libllvm15_0_50502-amdgpu";
      sha256 =
        "2dbf2fa889b86bc2834433cec92e02853999ba8a88035437ff3399e2ce67d570";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "2eb44df1e4b9cc9a1b2b5ec6e3f473541afe3d0cba301f443273a3061f0f3264";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "daffdd12454f253e1dbfe441f816bf4f530d300533fc1c61bcee7335d5620b75";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "f3a216b662a47843e9f4c505327a5ea15c539bbeec9c6a3122ef8ace25b76da9";
    });

    llvm-amdgpu-15_0_50502 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50502";
      sha256 =
        "7b7a8025c1e3437d09ddaf9133f0d331075e66550b03f526cc6f1715c628871e";
    });

    llvm-amdgpu-15_0_50502-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502-dev_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50502-dev";
      sha256 =
        "28e71d3bacec29d428c3f7e29a9793e5bfc420e6f99d3192aae03d3adcbe3b96";
    });

    llvm-amdgpu-15_0_50502-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502-runtime_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50502-runtime";
      sha256 =
        "010c1537fbeeb0848398e897c9a4f12a052ffb1c4d483aca9687d114c7172f04";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "cd28dd13ab469b9eba6b744e8746f5b81b1f2afeaca610da41a08730172ad8e8";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50502-1607507.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "98b9f6a965f081ef6484b36363ce83443fbad8ecf40b80e3a684fe5401ad57dc";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "1de4e135e77075fc1dc8d738799f17f6b562df1d3061ea69e0b890a9caaabe75";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "73762195ee321d0e16c10d43d138a6c2aba68ea5a320bcf9b0817cefecb8da49";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "e00cfedf90198dad93ba11ad23c177e5d96f16f32593e734f038891b2313e7c6";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50502-1607507.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "704d0eee6ca8d8f0851d4ab8dba0d0ba11bb44f61696fb8a6811f751bf94eafa";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.10-1610704.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "1ef69671a4a0f55e1e531d63c62247546a42e483057c56ae2a84f1b897f075b6";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.10-1610704.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "79f40a183c7f319ab23624842c95d869ac2e8c15a7f868adab2ecb34f629ca82";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.10-1610704.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "b9681c9f9f0e5046bc5fcb79c87cc290ef68272546c69394471adaa11143b799";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50502-1607507.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "3181760df9069e84c876fe665a9c253ff46075d757d6dcf5033edcb056b0b7a4";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.10-1610704.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "a30e134959f84b5bcc3261e96c524d93e937546fc6a04a730803afa72de346c4";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1610704.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "44308120f794ecbdf58c916461c9091633eb912faebdfacd157f7a221e2f433e";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.10-1610704.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "bb10a5042bf72930da28202befb1f1e3519e78d89c2e9424d0060d106360d931";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1610704.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "306d9db6e4e0214ffcf071345537f1d2bddce45c4a7e2c3a9a4794d96709f2c6";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.30-1610704.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "4472ef4a7da6d0a2f611dd9ca9daa484aa70b841ccf1f76e1006382f26759efd";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1610704.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "5755ab4dff2786f5c8db7e4eee5cc0e8f28718ca25de0ff3c035c2edc24902f1";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1610704.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "d6f9bf25e7afdd3b970a4085e153b2e58b182b1fbfd2ce2e4db9f8a3620eda7d";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1610704.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "cab69049946339cc424bf5ba7d61b3e9c0eaf0c4565583695de8a2ee9773733f";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1610704.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "805087531cba13f22423732dfc4ab14e4b4965bcbc4a3e846d37380d4b4fd04a";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.10-1610704.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "82feeaa589d6cdea8b0ad285b49e85cb49c8d2ef4db80a673deb836fd78a43c2";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.10-1610704.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "1865ad72ea01a93ffae91298d39dc19e0dd438790f3a295258f84f8243d76240";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1610704.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "05ca1d665ce4920daf71951239e4194d0f423f09fb254814a26f5206f0aed63a";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1610704.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "e517c8c50e6c3e8fe087d4ce07753f1c25cabe6e9597c2c082b2aecfcda98561";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1610704.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "963bec8e481997708072e03afc2215cc48c9c04727b0557d843f782fd871bd5b";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1610704.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "8bb2430672afff9c2c2a948d537ebca4effd1f1e90f052d9e13559f4cf495b4c";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1610704.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "a204106415c1febb9dc562a10a4baa219485d41fa4f13176e07766370c1eaea6";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1610704.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "04e9227c8f5d7fb64f551608b2c2553c60d651d14dbe7579cb413317d91b7648";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1610704.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "c0ae52d71f09451344c5ea5ae44e5bf5a5597988ef695345d5cb1cf2af84f696";
    });

    all = [
      amdgpu
      amdgpu-core
      amdgpu-dkms
      amdgpu-dkms-firmware
      amdgpu-dkms-headers
      amdgpu-doc
      amdgpu-install
      amdgpu-lib
      amdgpu-lib32
      gst-omx-amdgpu
      libdrm-amdgpu-amdgpu1
      libdrm-amdgpu-common
      libdrm-amdgpu-dev
      libdrm-amdgpu-radeon1
      libdrm-amdgpu-utils
      libdrm2-amdgpu
      libegl1-amdgpu-mesa
      libegl1-amdgpu-mesa-dev
      libegl1-amdgpu-mesa-drivers
      libgbm-amdgpu-dev
      libgbm1-amdgpu
      libgl1-amdgpu-mesa-dev
      libgl1-amdgpu-mesa-dri
      libgl1-amdgpu-mesa-glx
      libglapi-amdgpu-mesa
      libllvm15_0_50502-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50502
      llvm-amdgpu-15_0_50502-dev
      llvm-amdgpu-15_0_50502-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      smi-lib-amdgpu
      smi-lib-amdgpu-dev
      vulkan-amdgpu
      xserver-xorg-amdgpu-video-amdgpu
      amdgpu-pro
      amdgpu-pro-core
      amdgpu-pro-lib32
      amdgpu-pro-oglp
      amf-amdgpu-pro
      clinfo-amdgpu-pro
      libamdenc-amdgpu-pro
      libegl1-amdgpu-pro-oglp
      libgl1-amdgpu-pro-oglp-dri
      libgl1-amdgpu-pro-oglp-ext
      libgl1-amdgpu-pro-oglp-gbm
      libgl1-amdgpu-pro-oglp-glx
      libgles1-amdgpu-pro-oglp
      libgles2-amdgpu-pro-oglp
      ocl-icd-libopencl1-amdgpu-pro
      ocl-icd-libopencl1-amdgpu-pro-dev
      opencl-legacy-amdgpu-pro-icd
      vulkan-amdgpu-pro
    ];
  };
  bit32 = rec {
    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "7d2f63753b155bdd80ad82c4bfc8da122998604b8f7cc3429aa4d3010721af4f";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "82dd14d419160dd410a93dfbc975f44492eb29c1acb3e93e4b82c2413d23e8a6";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "ba314b92aa54f4b245e0fd0e02c2e18b47340e8bef7fc03959fdc52f27d03705";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "ffc8c59f00dbaa7dbded0c3cca1f484e686d4351bbf8274b9fa027c544d476f2";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1607507.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "1c484a8609cd8598baf7d87bd411724ecf1272d0c2be99fe03221b8d471487a8";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50502-1607507.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "3e133d1a0113544adb00fb1e7874771ce2e1c963af320ae14dfe150c029b2bcb";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50502-1607507.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "5a71d902a82deac092b0fa7d8d7f54126a3490f547d06f390246af9eee4808a0";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50502-1607507.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "4b2221ff726fd94d503cbb42be56f261e9c5c60c5fda8cffa9487272a7665c6c";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50502-1607507.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "387c1ecb39e247f8cbcccaaf594e1c03b96c00bb8b94e43681b54b464543ef11";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50502-1607507.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "d8d017f4c5d785ab09bf6e2c9a09c30bea13a272833d707f334b5bf4c6bba0b4";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50502-1607507.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "8523fee460420f6ae3df737c9f88b102f612c8d128926b8c1036e76f2eecf3aa";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50502-1607507.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "466468240d8716e044b7ad47c3915830dda41e910f573e414ba04ce74cdf5c10";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "acda275a698b91a68e2fb21562e080d7e0143627b572b4ff8859ea547595f7de";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "feb53d571a0929dc81d51bdd83aca76cf8003c27a74d23c86228b116773436c9";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "45ec6aaa392ef14a74dce3e667e85cbb241cc9d6d6894b26ac2be7eac7edafeb";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "af33d2016eb1ba8bad96454550fbed7c539e17f38e83154725c5fdec49e92a4e";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "514ba77bf820d4b3b6f6674716db83120436751ea2f92b9dd10671b1f1104e02";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "92f12489f686ad505b4ae9d4d087133d49a60f86ffec38662c3b8d2a965a7d22";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "e7a26effe97990e5523f51429b95c4e419a551fba42b4c304c9e162cccac0fd6";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "0253020758f075b511bc4e109886ecea82d140b1148f1a00a4360c3eed2b23fb";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "3b8f517f3405cccec3cac9df256579a2da7b38496534ac5c4d06b30cfa0f4ad4";
    });

    libllvm15_0_50502-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50502-amdgpu_15.0.50502-1607507.22.04_i386.deb";
      name = "libllvm15_0_50502-amdgpu";
      sha256 =
        "902ac7751de6cc83e299c977e951b440e8561c7f67304bbbd690c937d2daebaf";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "32d108f6ab0433c6e45a3f6dc632b2e16151e8873fe5e94d2419e70f7a75fe48";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50502-1607507.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "bf1360f4940936d2c15d89e90cd6ebf4f19ddfe368baa211fc92160feae6f5b9";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "2ed144724d39ab9574105a41678bb1bf910def055378c7f308f415a65408d9a7";
    });

    llvm-amdgpu-15_0_50502 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50502";
      sha256 =
        "57f75748864cfa1adecf49eef6c7ed5172f4e7132daeed898f14fc06c6a23290";
    });

    llvm-amdgpu-15_0_50502-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502-dev_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50502-dev";
      sha256 =
        "eff08d96e8b44005dce96abe59e782c96a6f7cf2dfee4559075d51980f845ec7";
    });

    llvm-amdgpu-15_0_50502-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50502-runtime_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50502-runtime";
      sha256 =
        "76e80e21907533799d26d012e09cebcce0fd7ba36a1752ed20cae1aac6dd5359";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "8bb218eb39a389bb3261e03f85b385a4aaebd4efe1f5939510ce71f1ac1a8407";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50502-1607507.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "1ee3804527ed32b8a52cefc942092d3ad39b69e17589d320a140d556d874930f";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50502-1607507.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "ae6954484ae3e17f6415e35366a5ff8ea354705816bc81da4403f42a1430ef7c";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50502-1607507.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "56754ec121a91ae2c0a13e7a4736420492389ad4b26ba26050f3090847b0dca4";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50502-1607507.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "ec107ccab98ceeaafbfdc47c3de6b054f9fc6edda1e905796b91b758c6b1a48c";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50502-1607507.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "646e4ae5ddb0e10cd6723c210e5cda7ba035f0cf01b5b6276d3c4a301e1e2311";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1610704.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "44308120f794ecbdf58c916461c9091633eb912faebdfacd157f7a221e2f433e";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1610704.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "e20ccbb96d0d9127d240eebcb11a3004052f09e660e7caf76b15dd1180d7227d";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1610704.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "7a16e92453ecfb88fa30d0bc016767c72a8af06b4f50e6c73561da991c2a6f5c";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1610704.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "ac9f723442773fef1ef5a3e87e45feb195089c7506887aa03433b427537772b4";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1610704.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "89a605e6bfd32bfe14e5cf8e6118cef8fba5689792364e02db6c35153bbebdda";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1610704.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "f9ab26a8840fd2481f17b6462a95c071e7c0cdbd8312c7cb027cbbdfefe28432";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1610704.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "b069c5b4c51d65fdc30a25aa619f0ff9d8acd9082a0f2d80aa7327cd7bd3ca09";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1610704.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "2debaf9911b3dea990b86c908fe6d965ff3ec274c52fce0c1454ec229538041b";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1610704.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "2a0eaf84689030ddfd57422ec894d56f005740f2b61f2ae59c4b08c1bf531aaf";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1610704.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "9d82125d4d24f64f99216758ab4d44281a8da7f381082278f3426fb59e245d69";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1610704.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "f0ceaca1c1ad5cce979ce98a5a01895cb7d03b0fb2a48b9efe292d2cfeb4ace3";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1610704.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "3a7a7972717353e3e025c5c14df926bc77138cb5ed0785acda958974222612b6";
    });

    all = [
      amdgpu-core
      amdgpu-dkms
      amdgpu-dkms-firmware
      amdgpu-dkms-headers
      amdgpu-doc
      amdgpu-install
      libdrm-amdgpu-amdgpu1
      libdrm-amdgpu-common
      libdrm-amdgpu-dev
      libdrm-amdgpu-radeon1
      libdrm-amdgpu-utils
      libdrm2-amdgpu
      libegl1-amdgpu-mesa
      libegl1-amdgpu-mesa-dev
      libegl1-amdgpu-mesa-drivers
      libgbm-amdgpu-dev
      libgbm1-amdgpu
      libgl1-amdgpu-mesa-dev
      libgl1-amdgpu-mesa-dri
      libgl1-amdgpu-mesa-glx
      libglapi-amdgpu-mesa
      libllvm15_0_50502-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50502
      llvm-amdgpu-15_0_50502-dev
      llvm-amdgpu-15_0_50502-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      amdgpu-pro-core
      amdgpu-pro-oglp
      clinfo-amdgpu-pro
      libegl1-amdgpu-pro-oglp
      libgl1-amdgpu-pro-oglp-dri
      libgl1-amdgpu-pro-oglp-glx
      libgles1-amdgpu-pro-oglp
      libgles2-amdgpu-pro-oglp
      ocl-icd-libopencl1-amdgpu-pro
      ocl-icd-libopencl1-amdgpu-pro-dev
      opencl-legacy-amdgpu-pro-icd
      vulkan-amdgpu-pro
    ];
  };
}
