{ fetchurl }: {
  version = "5.5.3";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu/amdgpu_5.5.50503-1620033.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "2df139e9abb9b773509aa1e10b2071f8c1976cba90c9e828865bcbb619fdabb1";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "439d84f4c5dc2bdd21eb1028b22d44260775970976687a81ad3ed5df19703741";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "f5e641366369ba334ab422af9e3d21852aeea5b5b01a1182d0ab6c6c4252de60";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "4092ec684ffd840e5b68a340bb77bcede9c7f6b7e20ca9d2c8e8d6cbd7a2b962";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "b6a4cb41977f3ca404412bc858f9c44daff159ecc57cd27ce4d714fc55e68fc0";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1620033.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "6f59473a300ef47ff158370635d00a6117b8e4539bb35e807a515e2ef39d2c1c";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "928a3768ec57ad5d426ce2f0a69d0d590232b4db7258fe65052bb3f75cd6f584";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.5.50503-1620033.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "fdab070a6196b048c6f81bd0c132ef34ba81b0acb40396df65d7c0f48b37a717";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.5.50503-1620033.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "91af5476d96e3f468593b5a305e175ab325d342b4798e5fad9ecccdfd5090ed5";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50503-1620033.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "759307b05b857ba4b0f4ab4a4ca3aa0633758de0e73cbadf72c959c26a9861b3";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50503-1620033.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "87ccaf55e02832b4ecc3931482891000a720614661b02509636d00486f321237";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50503-1630490.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "142f664971682d0bb49f84577003aa70561498605bb689cfda821563051d53c4";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50503-1620033.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "3d720b24920b6282fd4c5f087537bf2833685c5054ff611d86e01d9cd679a29a";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50503-1620033.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "46f2dac61247fc64a3c379f32fbc77471815ded752f27fa94f78c3c45b212a31";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50503-1620033.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "0b7b3454496a86a6dd38baa255d4989b7cf8225ccc21d46d2f46a7398df35ab1";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50503-1620033.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "8220a7cd9ebf9b681dd5b7dc6acf2c916c5605293f99ca4cff114387161e9246";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "b3db5087206b1206e201e5b3ca1bd5ea1e721ba81e51e0fd6bcc35ec51f42835";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "592b6c9c42ac4d37fc8852901b895164e508ebf976cd081bfec887abdb41d844";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "3825d8419cfe3009d9f4732092817a2cc5c823d490c4d278815cd9962edb5d36";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "7b38f02d815495ef49f5ab918d8305d380549456a6f5b3cbf091cdf198cd2fb9";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "1bd5ecb195cd3c7348fbc85074d54b39a6babc9ef65ef779a8b99fb7b21ae6b5";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "57449e1fa33da8ab0282da7dd50f1b79eab69b93c1f8b55e0fefaae0cd6d8189";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "96b6f6524b7ea375a4dc7664ca4d98a06f36654d9ece0ceb19d1c3175c8077b5";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "a438d0a572eafc5bf153e033d20d59f327a2307610908866c3eea9607210caf2";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "29548554a1e72aa879929c2a3fffab71de48c88d846cf0b51616ae663ad926ef";
    });

    libllvm15_0_50503-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50503-amdgpu_15.0.50503-1620033.22.04_amd64.deb";
      name = "libllvm15_0_50503-amdgpu";
      sha256 =
        "8fd723577b15aad292d581a499f4a5134847688bc4fda90fae8dffca946794e1";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "ef7e411e3ea91c70ba078b97c807f43443012734c18589df506a83aa21f01ff1";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "3e231699a64170ff0fecaf397ffa6c38d56f63a625cbae48e66d1998a16cf833";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "123016f28828db9114739ed8c85894f578a14deb37e289b4a8d5e141ac1d55a0";
    });

    llvm-amdgpu-15_0_50503 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50503";
      sha256 =
        "06d2aa184cfe8129fc6056849e06c8a55f911db935903d8cf76ca24320707799";
    });

    llvm-amdgpu-15_0_50503-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503-dev_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50503-dev";
      sha256 =
        "72dc7d06ac5e10732a14d8144a215951ea34ef4d3e51b159d88e19535755d696";
    });

    llvm-amdgpu-15_0_50503-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503-runtime_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50503-runtime";
      sha256 =
        "a95a2090b91d689a80e7d5c2d5fe3db4111bc0f54c59bbf0616a2105def7404a";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "986d88600b50d7f3f7f4f61845a317d96e244039050d812b16c60bb36a0e21b5";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50503-1620033.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "cce921f8fd51cdef6190c488c7f155fa24e0b374447cffa8e07937cd3b98e850";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "501bfc2bf68eb15812608dcd04e0bc722bf210998c8c68d8ded9779c66761ab7";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "b6f320f38d8d9d5466a216fe02e2cb3ae0e7781757bf5ab47a7c53bdaabdf8e2";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "1d8a7217ff2913916bb70e66709ca94e0ab5f95a7c59f6ba95197e19391e1190";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50503-1620033.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "98c57281b946f70cb6253a021f86d40f8e2453d981db17905f741d38921afa98";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.10-1620044.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "3106de3b8a9b8851039990b035969de336441e33255a2dbe422cba196c60c540";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.10-1620044.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "f52c81d1d7b9aa99c980ed3b04d23cb7a98ea2c99eefe48c7c80817fc1f78512";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.10-1620044.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "0a7a5661f691dfcd2235c9b0b72af1e38cd62404b5191bad7992c38d1de5f3cf";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50503-1620033.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "d9580230b509d6785712d1c96059bdccbdbbb2ea58cb940b6eaae4bdaf06fead";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.10-1620044.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "d01e7745c603d043dd31355c09d64d48e3dd0417ad2b486c59feaaa7334612ca";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1620044.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "17dd002acd256973d855666d450bae728c32e8af83686efb5636f16cdcafd099";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.10-1620044.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "b89fd5ba9b77b63984a48f8cf235fcd11a6b80a877418e61205455618085de11";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1620044.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "06ffd94f840cf5f9be1a33ba17a55bd6d5a7ee4c8aec61b61d28cee2fa30f36b";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.30-1620044.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "8d97dd0f579ec0f66fbb39193e738387c1a87fc4b390c5457ab85c7388a2bd18";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1620044.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "ccafa503361ca1deec5bd7dab1db9976e832a5b1625dd2037bce9faaf525de86";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1620044.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "e49358959ea9cd8e72c9eae70070f7710fec95e82d6df7aee2a2083d931648c2";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1620044.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "a115e81b4dc3260a74604e2f7337dcec7baad0cddd47d06fe5a97da7d377dd7e";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1620044.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "09af64d7c1ab60e7ad812fc2579288e7a90a5d9b6916dda1413177df8f3ce543";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.10-1620044.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "2dfeb21b2044c981150dc4208f67235e977481dfd2958e26e0061f8259781de0";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.10-1620044.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "927835781f05e42255c89828048cd51cb39121085525d0cfe2b78e90efe22128";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1620044.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "326f5252a6ae6dd62e4bd1961ac21a61daa5f5c7fab8e8be72d7ec195c2cc0f3";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1620044.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "7c9546e7b69a3e8969ec72234a669fffbf35be0fc6a157454f48b12776211f91";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1620044.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "e1a4a38acfd1a8af86a95a454aad7dc324d13ce37c70e70a17baddc07994d615";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1620044.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "0c926f42175ce785fe38fb220c423f52951d725b71d825ae5b3d54f5bf6d88fa";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1620044.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "3e273d857cf43bb186f8b66c637687af562e2e68e2fdea243039127b835f7b24";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1620044.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "dd2c3f427cfc14c5956dbd726ead88b07d08736a40abfc391011d84b2a44a53c";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1620044.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "fdfa431eba6168ad5feca3d0ad5736a9595d2923418905c767c3e84c7659157f";
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
      libllvm15_0_50503-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50503
      llvm-amdgpu-15_0_50503-dev
      llvm-amdgpu-15_0_50503-runtime
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
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "439d84f4c5dc2bdd21eb1028b22d44260775970976687a81ad3ed5df19703741";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "f5e641366369ba334ab422af9e3d21852aeea5b5b01a1182d0ab6c6c4252de60";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "4092ec684ffd840e5b68a340bb77bcede9c7f6b7e20ca9d2c8e8d6cbd7a2b962";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.0.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "b6a4cb41977f3ca404412bc858f9c44daff159ecc57cd27ce4d714fc55e68fc0";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.5-1620033.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "6f59473a300ef47ff158370635d00a6117b8e4539bb35e807a515e2ef39d2c1c";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.5.50503-1620033.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "928a3768ec57ad5d426ce2f0a69d0d590232b4db7258fe65052bb3f75cd6f584";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.114.50503-1620033.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "bd40135ba30038b180b4ede66430c82ab4dd8a98ea7512cb10ed8ec36b73eda1";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50503-1630490.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "142f664971682d0bb49f84577003aa70561498605bb689cfda821563051d53c4";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.114.50503-1620033.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "010a832ff97f6a6dc452f0016f617ef1ea83a7a10cc1c73f5554a5f923a412fa";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.114.50503-1620033.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "badadbcbaad839be99e79cd40e26e11f3fe7f1ec4f7196782974ea760772fdbb";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.114.50503-1620033.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "c481fb8f348ececa1ba37678e305a275303f36db6f58675e955b50bcbcfc3727";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.114.50503-1620033.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "9420bfd5b1ff8fdd62f34eb91b79f2dc88d1fc0b4ba8e1012ced4f3de83b77e9";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "2eae9f60466766b0962eaae1b0fdcbbe7d710c1b1f1fbeb998da523cda9c7e84";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "27fe1f1e8c4156e6765f87af2b92ac070eff7dd85f7869c92bdfe515eb82ee73";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "aaf1186cb47d2d45d3a079878503e90849d7ad559252b46a0ddd5ab7d859d2d7";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "ee1c5573d24027afae002fce8c856a6217afc33e20fa55f5d0a92b3c66d3f337";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "fdf9914bb976029a5b31a671414a5d71b41e25f1e7cdbfd6e3a5a75381a0bc08";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "bccefa81c74d9e6bbdfcbedcb645b2dc43bc920cffe4ab1036c44e6df47546e4";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "ed2b95bee12ca439107696a73592df7d93792c506329334e1737d390a77d4939";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "f661a04434294490d007fe49a4906c89a404f27c9bc58895d88b66b8957230a2";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "462c9c0c299eceabc9b8c25bfdc89f340d11ba86281fde52a6851c5d70fb2b18";
    });

    libllvm15_0_50503-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50503-amdgpu_15.0.50503-1620033.22.04_i386.deb";
      name = "libllvm15_0_50503-amdgpu";
      sha256 =
        "664890e22a94a9f868b9e9e4044e6073b5b12f7a00b2bca491065c273f520abf";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "a1d589164cc1e70e2c40ba5ba912a60ebcf5fc93f4d57061e956685a4abeb900";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.1.0.50503-1620033.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "5643ac19de07bac6a7ae858bef487ceb42871d347803e63ff07134329fd444cb";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "a6d060835902aea308bc164bf4b095418b70ccfe728284c09ffc35664b68281e";
    });

    llvm-amdgpu-15_0_50503 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50503";
      sha256 =
        "c10b5875b7c4b01cd8db13405443a3aa6135e701ed1270deab0eb139b0a6d22c";
    });

    llvm-amdgpu-15_0_50503-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503-dev_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50503-dev";
      sha256 =
        "b27baed2a4dfee6c74bf498a2a3b460adb270e3505a5b02a6419d9c4a1094a8a";
    });

    llvm-amdgpu-15_0_50503-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50503-runtime_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50503-runtime";
      sha256 =
        "0913ca11a57c31c04e66cd1e8dbd26ef33c0a0e217ecc58c0c8785b2295334eb";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "6402ba6238f950e1e24edf8708217f4c09815f95a0240ba9eb83d1f92161363d";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50503-1620033.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "f83f73148c787d588e10e1cf99341efd8ceb0622557c87077b764fa28e929fd5";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.1.0.50503-1620033.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "44ce9a8c632a91890f5e8cd94f33834bbeee729df70c858bdf294faabee3ea26";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.1.0.50503-1620033.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "89f5fe4098283b8101969f66e016def532bfd5b89e740e2e841ce9662fe1bd78";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.1.0.50503-1620033.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "c8f682d87bfc52756decca4b03da4f2aa7973fb2e0ee7cd026cb54e61583f244";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.1.0.50503-1620033.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "6b97beb7eb57cb68fd3f95f5ceed860d0bbaf3b45d696dd50afefae25e6ceb04";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.10-1620044.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "17dd002acd256973d855666d450bae728c32e8af83686efb5636f16cdcafd099";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.10-1620044.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "593fe55bb12ab029413ee9824a4808cafb8b05fe61ada52dfde9dc990479d5b8";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.10-1620044.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "7487985576f13aa29024d3a913e0519e47995e2d3001d2e8eb7ba4e0580ad46d";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.10-1620044.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "3946dabb829a48e00ea351a8ae048a3dfc46bfe3f69b343267cf9690b49dc961";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.10-1620044.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "a0d821c82cb2a91953c08e4e895da28749d905470a13ce03bee5937959edba27";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.10-1620044.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "f677cd6e4dfa007e12bafb96f8a3fe0a68c15f90fd6644822c701795ef246a4c";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.10-1620044.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "4fdc52e18a178230329c4eca2567bd1077b47334614d0cf6e1f7234289b05374";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.10-1620044.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "21df77d705ee11de4303911a8e29eb14f38b775b48da9ae5d00467ee50a9ab52";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.10-1620044.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "efb6f688fa9932602de380735f495d04b393f8e349949b6f9fae57ee5494e1c5";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.10-1620044.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "e6a4bf971467ffa609aad27831f7a90f0c0ebb3c956fbc810ccd3d3a1310c2d3";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.10-1620044.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "705fd3dca144f8c8800f9657e68e2445d815d742c44b24068cd0fadb569ce0bc";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.5.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.10-1620044.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "c5f131368336f7c48639e75c1a18c58cef9e32598682a59839ab0567f96c799a";
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
      libllvm15_0_50503-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50503
      llvm-amdgpu-15_0_50503-dev
      llvm-amdgpu-15_0_50503-runtime
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
