{ fetchurl }: {
  version = "5.5.1";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu/amdgpu_5.5.50501-1593694.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "cb7ec90a8e417dcd6513ee5df17702c9f738f9ed9254ebeb27666966559f6363";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "75a0b8dd8e4c0ad910a462e586c96f13de821125e2a3093fa68aefc2f81e2f8f";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "b194c38b5426c32ba69a4f9100a8072b8b1799ebbc92d4c998654eab40a212a6";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "51e702346e9dee960e65888a19e182642037deafdf200d8c6a98cdc85461c04c";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "569b24c36b89df6ceb237b0b589a648864e690a262001dc04296ca56dcc77567";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1593694.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "c442099603eb8a669ea6a35aae2d5e7e27f96fcd8571b890a69e0fc045ebd505";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "c3ab398431a8eb4ac36a217f6c879c9590923ce286e8c8ff99da02448ee63735";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.5.50501-1593694.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "6ac396b6ef4e7808c1c2509ff0cc45c6a6f9f1a5f458944ebbfbfc01793ba73b";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.5.50501-1593694.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "4fe21d8ba426f91fee7aebdeb3b07e9b816af5e1d2aa05a6745ad905f598b905";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50501-1593694.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "d24a3e8f4569c6ee5d5dc01e3a30e2c8929150deea75bb72ce5ebc021f2ac07f";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50501-1593694.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "21cfac9815e2cda7b56932c8aba5dbc1e4f24ab04e46b0d6935d7a2d9531c8a6";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50501-1601188.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "3c1a4437f7e80695a5e26a704e659912fd2bc21d274d4f656e6de324cc6fbcf1";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50501-1593694.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "527ffbcbcbb0af260ba98a039e468653e095695048baa12821ac9a668e1b358d";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50501-1593694.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "506b2ad33fa8f6823e0f2a9fadc42935996180bf5d2a06f955e728894873af21";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50501-1593694.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "0c1962c341b7e2d04e19c91aa9062d369f6a57f7f1b75d92173c9a80164d241f";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50501-1593694.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "04eb6c7c8596fdbb94a2010e504421dce02d2b72d9dc284c6368a7e605b2f7cc";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "8fc7e0d15013fda2e97f2bdea81cb4d71bcbddb4f981b3928a9b7391df557bdf";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "98c32335c67804b3886228044c3c3d1aadb2b8f6b1747ce93b9d8d250f52c4bf";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "b9e67e3a039600e96325f677e270eb77886502382b29b67cdf6d1034614d2027";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "56e707d917e51511b9d87872adf8617a675cda74f70c3dd34ad8de1d7cac26db";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "53bda9009c9ecc004d074944d461f7d05ba20cd4c330d6cd8b7223f76ec80fb2";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "f29395c5f514ae14585daa9599919e21dc0e2d64ffdd11002e934b68fbf09b94";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "278fe694cc970d190251224cd21005b32f0045e630f9f1737db6693958c55c8b";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "33690ff0aecec3425e3479071c0b8a3ada19a2aeb425f5cd0b5e52384bd90af1";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "8ee78f66bf0a283963444953684b188457288e62a0fa5b32170d3dc5a7fa5d0e";
    });

    libllvm15_0_50501-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50501-amdgpu_15.0.50501-1593694.22.04_amd64.deb";
      name = "libllvm15_0_50501-amdgpu";
      sha256 =
        "1f1315bb63a6bc1ce178f928875662713396c5aa9c2977ba37ebda796cae0835";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "b657c2bd795ef4a08900e826f23842d52c15eef162b2347e3ac0a2a026a3a4d3";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "ef2f7cb73b40f762c34f80bd53d8d394c845358cc6b8b2ca3fafb26638e6444f";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "3e1b080862f24c1d0a6ac294612955fef4997d992c9b6b30cb7a993559d8b5ee";
    });

    llvm-amdgpu-15_0_50501 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50501";
      sha256 =
        "e66b49783e15de195a2e41c80a6345233432b412d77c780ad910451b6694d003";
    });

    llvm-amdgpu-15_0_50501-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501-dev_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50501-dev";
      sha256 =
        "7f0c4d717f75d59364da654a2e1538259023c85fba58eccd2f417ac744adff89";
    });

    llvm-amdgpu-15_0_50501-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501-runtime_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50501-runtime";
      sha256 =
        "37969fd33984601dcdd0b2ec18b187ef207e1a13e4d77792a27f3f42eeea3f4f";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "6ca1911f7341a7428c026d16f473ddc19ab7cb9bf39421da83e3b3356b6473d5";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50501-1593694.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "1f573220c4df7a076b0101898c5a40918285dbbbc3392103992b0c389929c671";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "084bd2caf1ced2d457eab4c5072bd04ace1c2ac5410ae6c170e946d555fee251";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "5bd829aa4eda74cec82067a01c03ece8d7fb9d3c07cb012da85d3e0b6b2ecbe9";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "65e6a5986b8039c5ee371ce16c7160f50b3f08f6acb740073f8e9cd12384dbbd";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50501-1593694.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "b3a0aa0602b33cb964018cdb9249fcace244e6162e0b2984e8553c8fe6a49475";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.10-1595145.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "8e31e9c154dfcf0ecbf9954062785313a4a481473dbccc498b3fd4c9991a52da";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.10-1595145.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "ab9f7468d025fd76ab8f2bbacd2e349af4620c57fa2fe3e643ecf341df1b8173";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.10-1595145.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "5f49750c8bc014064daa22c656f6656e30302998437645e215ddecf9b1847195";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50501-1593694.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "48d23e72c65b98814cbd1adb508f79291296d44bec413e4fd3e74f6c7bf7345f";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.10-1595145.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "cb1c40fd301f3f662efac996b16bfe7282397bfbb45d21e7806ec6b7faaedf48";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1595145.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "18eda8f74e7145c0518d4b3b8dc243a6621dd9c409406c6097d69bcd942a295e";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.10-1595145.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "0dd8a086da8cb665090c80c8772e2237d83c946e2f3ec23d8e21b5f76c1dc6bb";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1595145.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "4643ba2b4b19c1ad7cacab18bf84ac0abf2c56a0f5ebd7e8203945941a95d458";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.30-1595145.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "f1825098d8ea4efa3999094761ae5e26005eebfc3481011f4723f1cfb514b89f";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1595145.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "861b8fdeab71210bc5767ec8e443dc78c202dab605ef3270c55085ccdc238c01";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1595145.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "c0101de4551d50e1874a25f3130843dc2d01fd5e007b4be4db4468c66a66f605";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1595145.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "3533c597e6e16d3e2d25726c51f1bad1b7ee8f083e72b13b6365ba0807f44a6c";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1595145.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "e694fdd17c0abf6aa4bd11737d97eab0792c611fcab3a283dc9740ca18fdc725";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.10-1595145.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "61def861b132d76d5a9ac43c3f13a39d0206a3f409ccd450c4788351ef5c9777";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.10-1595145.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "13e4f5f77fbf43a9dd1c0ab595ff233ecc45299ff4489c10fd70498e0555058b";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1595145.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "5ba1faceb840ccc0cd235e01efc54b984028520083ba41ef0a4392acb56da81e";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1595145.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "9c0b42db7a0cd0372cf7ca43b1ddfa75d0a0b9584d7ea22c964bd3a2f1b3182d";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1595145.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "4754d1663625fd93d1dafb88c5ecd2b22bc3a818cdfbeec865c4e61c3bc750e5";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1595145.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "8f4ea2cbb5cc35d07904cfa64536ccde61400aff3d72b11217f4a188ef8bc9f0";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1595145.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "6f0f780fb2c280fb885e2c35a4833ac513fe7aca1265dbc7f088b352e191a87f";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1595145.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "6067a00d5870523f243db923e6225db1c31e09232b21f9e07ebfeaa5c462423b";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1595145.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "3af060309f6da74b901a6adc4acc622bc73d36b6086fc77f7d69872a6229ac52";
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
      libllvm15_0_50501-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50501
      llvm-amdgpu-15_0_50501-dev
      llvm-amdgpu-15_0_50501-runtime
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
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "75a0b8dd8e4c0ad910a462e586c96f13de821125e2a3093fa68aefc2f81e2f8f";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "b194c38b5426c32ba69a4f9100a8072b8b1799ebbc92d4c998654eab40a212a6";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "51e702346e9dee960e65888a19e182642037deafdf200d8c6a98cdc85461c04c";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "569b24c36b89df6ceb237b0b589a648864e690a262001dc04296ca56dcc77567";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1593694.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "c442099603eb8a669ea6a35aae2d5e7e27f96fcd8571b890a69e0fc045ebd505";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50501-1593694.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "c3ab398431a8eb4ac36a217f6c879c9590923ce286e8c8ff99da02448ee63735";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50501-1593694.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "8bb380fc85d039a4533850f9cc37725ca915c42f86db28516a5514a2b1ac2bf5";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50501-1601188.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "3c1a4437f7e80695a5e26a704e659912fd2bc21d274d4f656e6de324cc6fbcf1";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50501-1593694.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "4cfb01930a21cc000853c54d0c7be69284bbeb7061306ee3f2184d2cdb3c105a";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50501-1593694.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "6c3c039d4c0d2115595228933bf36c2b9555157c255d964d34010bd5b299a5ef";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50501-1593694.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "646165951747592f57ad2e28c45a6f9c8e4783e6ec0ff8f0425a9a7600954954";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50501-1593694.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "545b14bbc4abcaab8058c16c0b7be74f28fd93101273bacd380017baf93aec72";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "3d635c3dcae2040090704acdfd36a1e0553bffcaf21c5e0898e2a1060cdeef8d";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "793b9376e47131ee337f547cd6babaf43c5795376b99285263d05af165915c92";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "e6f91cb49abd9ff336df21c21d547baba713471db7c8c32bdbc8d3246e997cce";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "c392639ee41692eb6f5563d96eeeb128b5ef49e9d0248109d10cb5e077d55c15";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "0a543600b6ee799db56a658b4d09132080034a6445edf561ef3572bb7ee768cf";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "d86d83ce23dcb96bbba2f06610f25401b1c6e8c7487a28b272af9e51c03e9ed0";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "6a3282b0875ec0e47e7668573f8c2c4de364ee119199b7aa40c38197f1cc762c";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "36489021882fc2cbde2ba9b21387ef335127311d949418bf16dad1f37d23f74b";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "ccd3220c98e6fd08727e4344b03b03787b0dd93a5b4ed397737aceae345df0e7";
    });

    libllvm15_0_50501-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50501-amdgpu_15.0.50501-1593694.22.04_i386.deb";
      name = "libllvm15_0_50501-amdgpu";
      sha256 =
        "9d6ca9d46aeb5ad49e17aeee4cd0eed47c3ef4f5cec0dd4563cf6adb99a141d9";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "66f8806eb60fbab8c65ff1f526a0cb30523d88a6eaf4e0f76e8f460fb59057b8";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50501-1593694.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "8758effad09c4991382ee55d821486a701b99914d4d1b789083835482ae913e5";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "61ce467339862beadcd198194335e95fc256041abe8f876561bf7b993d944c42";
    });

    llvm-amdgpu-15_0_50501 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50501";
      sha256 =
        "1ee61f0a06d2db11e54429e017741ac22d0bc04eb54ffee23e21c8f4cceaace5";
    });

    llvm-amdgpu-15_0_50501-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501-dev_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50501-dev";
      sha256 =
        "b3c331958b97e32c0d4c8f5a985ece559eb2054b8079ddb64eb9fcffdd8a430c";
    });

    llvm-amdgpu-15_0_50501-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50501-runtime_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50501-runtime";
      sha256 =
        "d90bffdb29e1b89648f0022081e6ff0c5143eaff21d95ca13870c5ef1e9831c5";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "2c398c08f01be0ae02a219051984f8967823fe6e96a1a3b5a1dfd029af18e0df";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50501-1593694.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "a7f47194fb8adda74c2eb9fef109c2d3638ef73db77478c795cd09d284401b58";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50501-1593694.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "08787b8d789ce91ed4e0d0684582b2cc17892532196236038faaf784a6decfc1";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50501-1593694.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "33b559e5e9cdfb2527d789d6dd451b584d2212e75e34dbce85bde2073a800738";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50501-1593694.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "082f8b7700446121347cdcc70271fe1092d0c272c810b7d51eac5acf9401db2f";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50501-1593694.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "54049df470fe41d53011950578f0cc54b5efffd5e47fa7bfc1e575749af27283";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1595145.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "18eda8f74e7145c0518d4b3b8dc243a6621dd9c409406c6097d69bcd942a295e";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1595145.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "651018eff2ab0a202f971988d834bbfb659350556a47edff648d9ef7660b78e4";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1595145.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "0c0ff56a7e3eddee66db335cb11931c0d85725dfad88c6985d1150fc5618d7bd";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1595145.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "8961a5a19a5b8c84d54df6be125f494fe238aa28267ff1778c9e4e5384281182";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1595145.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "d633fb5c54956a8247cffe9f69f9ad57fa2aaaf4c273f8b1fdca4717ea2c41c4";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1595145.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "114a225282cf6f7e2a1d0ab84f716ca6a93dac6c2cc186cd3f61aa32a5061af0";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1595145.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "ab3f9016b66940f6cc04544da8c576ca2d5d7482da570637b40c0a0d0be1365e";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1595145.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "5cb48db10863235c56313bc18a0867d8ee1ca04d46b5ff072c8fdbca586eb395";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1595145.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "9ded5bd54f3a4062f013f8547c8829963cd2ca17fd0fd43cab3fff33d28dab02";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1595145.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "025fe59f17398eb81e89277c78eeee2bdda2091a7b1cfba47dd7bb2e4fb02688";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1595145.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "77b6e73bf3470184a152fde6054a67d3d4a5b1bd50fa643f3a3f447b2eb6c28d";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1595145.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "7e3dab457a37bade8306038c8f126ddd3438d31e5eb44bc5566ab41e7291870f";
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
      libllvm15_0_50501-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50501
      llvm-amdgpu-15_0_50501-dev
      llvm-amdgpu-15_0_50501-runtime
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
