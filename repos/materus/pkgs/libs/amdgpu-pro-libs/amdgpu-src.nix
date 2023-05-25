{ fetchurl }: {
  version = "5.4.6";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu/amdgpu_5.4.50406-1580598.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "768d406f6fd4c174d9628b66f432630c15abdfca67c6d9e21ec5363dc5a06c56";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.4.50406-1580598.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "9f05d21d16610733778ed621bc0f654db2a78a67b6c03f9c7f442d278deae778";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "bf40e95d9006ceadd0b52e7d4e09b8d189d0af9ee79c9ba4e0ff48652bbf3444";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "7701fbb95900c2502aba03f4d3d29f1caaa935191bf21012ecff7ffa0f631696";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "1504976fd0b61f3bc11e32948d3f6af0b9f52e8880c90b3e298ee37a557f4c2e";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.4-1580598.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "36310f80c30bdf1a4d3a95535533a72b062707356456ab1757282c9c9e4b3958";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.4.50406-1580598.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "026cd50ab9d979710ca023597f529fa5fd1d474513ee81def09f64c84c4e33a9";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.4.50406-1580598.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "3fa01a0ba61256f67b092b1387f530ee13eb53c63a1ff05fc1702094431fe1c9";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.4.50406-1580598.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "de4309c608701f5961784a0edbaf4ab13e4f8701b33ecb3c90cece801c2a0e26";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50406-1580598.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "9003db44efdf85eb2bd925e0f5838e9676e3e0771665ca6cef87f05c442d3126";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.113.50406-1580598.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "864469c26d1fec06fc4fe7912b92c9950d487c6af6b73aec439eab03f00815de";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50406-1600687.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a5e5d9d868e6cf856fbf0bb82ddbca4b2830b45e0204fe57964301770602f8dd";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.113.50406-1580598.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "2a3f8992d180f9ebeab5ca639e528bebac3bd4e53a56e66493758b3659dbec29";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.113.50406-1580598.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "ac952f6b846728543e9ddddf0420974c883cb232bbe94c91e8aa513b11657911";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.113.50406-1580598.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "b42cabb8467677f95e47141a5c11324b915673a64d71b60a51086eb008e0c03e";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.113.50406-1580598.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "fc47865500e1de145b311cc945989159d9a26e3886b2810b7995103b9a975528";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "26a524147099d418facc387a742622bac0ec0a50bc1c1bb401439050b74babd8";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "8e0ba88b27de2d9c948c68059cc6a94b83aff231c4aefd2b85c87cae61618196";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "ae5e5aa36b03bd7e083d8e73afa6e73adbcee4a12530807636e0d95c4f1f9c94";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "d2101b5d1b4bbe754799d32aae7c853bccf51ab8088e7fd8222a9edc4ba14149";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "2e86624a98dd9f26155465050dcba321e1b2e495ecc29aeb10188349138cc3dd";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "8e32c59d67a5bf6cc8e0025912f7d4ce6a01e738f24017a8c6ebff56734abab5";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "54dcef35b97adf7ade66a2535f8591f340c58aaadd917d51eb4dcd69596d35ac";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "7fb235233e115f698d9e36e16706bd9e795b46023038f61e11f8d90d672581e1";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "4e360f7d3f96b7c7cb3a47675dc5be9732bc312087a629be3afa828d23e77cc6";
    });

    libllvm15_0_50406-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50406-amdgpu_15.0.50406-1580598.22.04_amd64.deb";
      name = "libllvm15_0_50406-amdgpu";
      sha256 =
        "1c606c3de98d9874c8148831b815e3f74e089675360927f85764cd0b8088b18b";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "5cae893e4d35b000bd297f006367312beee42ba1693984dcb4321734bd992198";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "ba46f5ba6d5ca5345d8188ad9cde2b8ed7a7c402f4ef7153d6b1d17c5c0ff00b";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "acf6dc8aa7d0656db8e490a50e143f7d0f91fe908d6b63bbeb6a8f270deb25b2";
    });

    llvm-amdgpu-15_0_50406 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50406";
      sha256 =
        "8abf833ee4ccfc3075cb917d44ea4d08d7649fc87a2251e6658897f59df12d0d";
    });

    llvm-amdgpu-15_0_50406-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406-dev_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50406-dev";
      sha256 =
        "19850d7760c5d9f2e16a05178d8747819393b2636599402266ec5a65d9167cf0";
    });

    llvm-amdgpu-15_0_50406-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406-runtime_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50406-runtime";
      sha256 =
        "bb806e6b582f1dd0b001a3628087d2e2790b1391b33ae2d514527afe1bd92310";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "f0680c2826f8c62a38744efdf1c9786ddace5368659cbea0d6caabb8ef3e9475";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50406-1580598.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "81eeb0c035b4f54e0e32b7257d17c7518bda5667a784a95672e7f392f1c5cfa2";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "dd69fdfced9896d6542ce2c5ea5d7bb63076a8edd0f35a7b3b7b75d85f23a64c";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "582299e92e402c78919ae81bc1a9e8916c1d35ca31aa104d60b5bb800bc8afa7";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "d7c87747dc10324b1cdaf904fc46c312c517d6372b6c937bc98c29e200d3d1ef";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_22.3.0.50406-1580598.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "85a17a4dbc10206fabeb9387dab507f56c790d738ba15ab7227828d419887f51";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_22.40-1580631.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "f7c29dec3c2266741eec1e0fe468ef1bcaddfb18455fdbb0d1b3c6bc0ef626a7";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_22.40-1580631.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "f17ec1b6e4018fe57f3cc32c5304c23666e4f9d56c9fefad44f225d75e1552f7";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_22.40-1580631.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "2c1f98534164cca0af1e6cbe1ab914d08c8fd0147d9169ec18c9bbddfee12834";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50406-1580598.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "d3416658b521d18b33d1de260ee177b0ecc76c40beaa1d7a20d77ef2d574d889";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_22.40-1580631.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "70ee76db2f2d0d05587a64d28252a1cca2fa6b665589656db5e24d1e1ccdb521";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_22.40-1580631.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "b2ff71c9d55e23a5a5f1682975c28e979d0a0ef16442fb51f7ecc9484cdb56e8";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_22.40-1580631.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "aeeb677906eab8ef6e3cfd00f4294c02758226300d3844f6abf833bc8cb7f12f";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_22.40-1580631.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "929afbe00fee9433b927b64566061b10c5cef074398d663e7e9f4f75a26719b5";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.29-1580631.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "74aea857158ca768b1a5304c40645922ffae3759a2c76f273c6344f215a6899c";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_22.40-1580631.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "87fe904e4a4450fe0feff105e7c66cc784dfacaf8114d9af42ba39ba2f3016e1";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1580631.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "33229bcc7108afb96a31b23a474db1b02dfa60e4bc936749e8019ec0a107d3c4";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_22.40-1580631.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "da66e0f117d4da537274559f66ddb0bd2534fd20a5d9e3ca2d70419667a6d72e";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_22.40-1580631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "b622dbeb0c98e968fcdd7efb4a83b49233a6349d2ac1f012a188911c590f3584";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_22.40-1580631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "0e340ff0d8eb90a1bfb31eb6b68682ab0039c289ce8738f5abee394b61034f06";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_22.40-1580631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "6dab7c26ee395ac66f1c70e5c47bd058ff154baef510b093475baac62c5dbd47";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_22.40-1580631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "9937c585c58878fadd54cfe3822fa1b95aa6513085a9809c48d72d924e5d2e67";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_22.40-1580631.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "0ea6229ce447f755069ee416bf6718e0ff34118320a5c4f1970f3e94f362c444";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_22.40-1580631.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "6d5d09624d29e0dcdffcda80f97fa717894fd0d2bb2ca4f32b9acdf52c2524e5";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_22.40-1580631.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "e120529cee5feffed40c85bd91f5e9897585d865b67d10964699b1641197d0a2";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_22.40-1580631.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "4177aaabc108cfebdd0f774ec289c544e122b35039019560de3c732d60e3438d";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_22.40-1580631.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "0034e9774d0c335069ffac0a35a49c90253425fb41bc1eaa18a86837023f01dd";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_22.40-1580631.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "d91b30d640bb15ed3c28d2480d9c91f67705ef4ba81aaaa64a91886485f8b6f4";
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
      libllvm15_0_50406-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50406
      llvm-amdgpu-15_0_50406-dev
      llvm-amdgpu-15_0_50406-runtime
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
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.4.50406-1580598.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "9f05d21d16610733778ed621bc0f654db2a78a67b6c03f9c7f442d278deae778";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "bf40e95d9006ceadd0b52e7d4e09b8d189d0af9ee79c9ba4e0ff48652bbf3444";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "7701fbb95900c2502aba03f4d3d29f1caaa935191bf21012ecff7ffa0f631696";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_5.18.13.50406-1580598.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "1504976fd0b61f3bc11e32948d3f6af0b9f52e8880c90b3e298ee37a557f4c2e";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.4-1580598.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "36310f80c30bdf1a4d3a95535533a72b062707356456ab1757282c9c9e4b3958";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.4.50406-1580598.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "026cd50ab9d979710ca023597f529fa5fd1d474513ee81def09f64c84c4e33a9";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.113.50406-1580598.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "9504745a956203228e8559a8c0a7e52e9d70758618fa5c933512eb29865dc32a";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50406-1600687.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a5e5d9d868e6cf856fbf0bb82ddbca4b2830b45e0204fe57964301770602f8dd";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.113.50406-1580598.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "af33f0e3893d7670a06bb0a774a95e96237aa3949cf86551c097ea6fde544ac1";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.113.50406-1580598.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "cfb1e5b8897b645c771466c9fc0fe1a7b80a0b89a838773325aa045a789852fd";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.113.50406-1580598.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "ba9438588faba94c9a7eaa286599573964e1d116c851a638f5920eb1c9a996ef";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.113.50406-1580598.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "309eb7c8e637549c8b32a4c27580c8cb5e6ef4e1bfb58abdf4161c97c11f6684";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "56910bb02fb7813f2e8acaac6ff0f7ca49fb526e724e1b31acf4106341d1e013";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "300469f979499cabe34923a76705ca6cbb6398b08efd1f5d0f321d70bd3814a7";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "b686e92d574dc4de88d9c45af21cff6f97571af59fa3ccf44c6685e6490e1f52";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "41037fb25b1436811a49927721313c7d38e1f717d7d43e0be701e54ad1b75722";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "3c4cd3f6fdce6a9230c9dcc3afc01eef8a04846baa94d1d1cc881e5d5a6f8947";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "66945bc8fa11253d064772f683f76c8832c57f794db508b6f62b294189e9a43d";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "c4733c55b6f69a1b988a8fc8422aed1ef69b667221d15f4b052d7954a507a797";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "bf1cd27b2a7e5cd00cb1606451e2ecb74d9b483d67496c89406b30f54aa9a133";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "eaf42742d642d85f2153c06b0fa31af470b05445620a1f0e557aa18227b4988b";
    });

    libllvm15_0_50406-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50406-amdgpu_15.0.50406-1580598.22.04_i386.deb";
      name = "libllvm15_0_50406-amdgpu";
      sha256 =
        "a4b0cc707b36230927909b5b923efe8923f820f54bfb1ca3ce317d18d050cc7a";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "a2cf1889ae8a6fc7fe374c91c0074c084cb0fc6c6ca25878a411c010244483e9";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_22.3.0.50406-1580598.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "8c017551d5d75e896ebddd632ea8d1beb35450398f86c50ad6926db1f6dfc6ff";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "1a8356ae8d21f13d895b50816181182edc3bbe49c3b30428e8c8b4542917dd7e";
    });

    llvm-amdgpu-15_0_50406 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50406";
      sha256 =
        "fcd61fd7fb093fe37f6af745aa848ff913059979bc29a0942197d83a1d9dd97b";
    });

    llvm-amdgpu-15_0_50406-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406-dev_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50406-dev";
      sha256 =
        "aeb3873bd040b45245e6b020668b98df4f3f60e45c6f84396b2bbc0c2f7266d0";
    });

    llvm-amdgpu-15_0_50406-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50406-runtime_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50406-runtime";
      sha256 =
        "c555ca79783834464d48305194a5392a65785b68924f6e43225da002a65deedf";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "8f3320b1e43ee29dbba83ea0d2e8c20acb4453cb7afa4aac3cc87339299a899f";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50406-1580598.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "8a2d9ce62a12e5fb806d9901137e8a8d6ba40ac93457d7285dbe38e4eaff0f94";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_22.3.0.50406-1580598.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "224fe660f1614e79d4dd0f22bbcd3c4115df1b63a60ac63fdb5d3ff255fd6822";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_22.3.0.50406-1580598.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "732339924060eede8653ad00e16b7b520c90516db5f2cdc19386b6cc0f1aaffc";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_22.3.0.50406-1580598.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "bfefa69a9084056d976da2b15905edeccebb0e95ebf15b738cbba4893710a627";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_22.3.0.50406-1580598.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "20b15dec93ba8a5f1304c490e654436c38f8ccdff60530048d4a589afbd92d46";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_22.40-1580631.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "b2ff71c9d55e23a5a5f1682975c28e979d0a0ef16442fb51f7ecc9484cdb56e8";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_22.40-1580631.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "ba41a037d1549e9dbf7dbee3b8c91f94d58b954af27a7e79953d532837f6e2bb";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_22.40-1580631.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "b63a30e3265c0b24e3b4d89f273a3200c96edd38a8bd6bc3b7a6697bc677ef48";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_22.40-1580631.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "237fb31fd968689271d597197a18eac3209bc3e6c222c28f96f7ceccfb895a44";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_22.40-1580631.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "55f3916734244fed6d7feaedf2056144612e49b27d2be13053e2575dbcfe3914";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_22.40-1580631.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "2e5f84a61b395e5e8965ac9aa1dd51d4827b795329f4c752ebc0dca9844297e5";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_22.40-1580631.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "7b009b6d057dfe302e5786509e5ab33bb3d0a4ad4397969617d8f0c3b40f6846";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_22.40-1580631.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "9c95b87f1ddd12956167b5a02cc702b84a367a6b4ebcff55a8d516e825bfefda";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_22.40-1580631.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "ce7a67630ccdac9bcd37ad1bce3b22c601dfaa74631155eb392cc09ebdf92616";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_22.40-1580631.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "edffbcd3ffa770a4f3624ca232df575accd395a953dcc77a9e00e7a0487b1be6";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_22.40-1580631.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "521520e5fc1259ceb72a0a6a931779a9fd40b942fcfe427768593373800e0d96";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_22.40-1580631.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "408b74609845dcf256a9da17dad8c8dc74adb2d16da2078621e94d0d847ebfb9";
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
      libllvm15_0_50406-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50406
      llvm-amdgpu-15_0_50406-dev
      llvm-amdgpu-15_0_50406-runtime
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
