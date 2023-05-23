{ fetchurl }: {
  version = "5.4.5";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu/amdgpu_5.4.50405-1577590.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "996aac718c8c6c1783fa48ea99d4e4c5cd93462f5d0c2d21aaec44125523536d";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.4.50405-1577590.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "edbcca28cee851b0a99768fe2d226c298fbef87348f2edf6d3940c0ff96188be";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "07347e5c2d32fda267b4a9863a3cf3740b8cbe1124362eceac3b485981677f70";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "a8a55f04e515eaa383d08a19aea29852e3c9a087cf5e0869166f8aa235954001";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "30f6d29a0ef53a6905a08412b0837339c2398cace7fab7edf6dfab60ac7d631f";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.4-1577590.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "7a84f31e196fe4bece810f24ad80b3d9a1c93dc9d276ca56bd6b4e3dac38d8f0";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.4.50405-1577590.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "f7cd6f46e7286757795ca44c1633148ec128bd9892abd982467bd43c4efbbded";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.4.50405-1577590.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "53694e32d9e20aca9e0bc16eb78738c4223d4a46ee7c5502ade951680d1b543a";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.4.50405-1577590.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "62f56a479f21c1d3ddbffb94cb38c1e220cbb82cae5a51a0a228c8f61b88ff9c";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50405-1577590.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "829d5b3ca396965921b41e59cc7cf426443a285fcd0b389669e5f9593e147032";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.113.50405-1577590.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "9188156e1f08b3f1dd79416d562586486d1d6958b77756aae35a834aabde30b8";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50405-1577590.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "71a4a7fd47473124a3520a241934552b374ebfa4957970d6b19d50d60344723d";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.113.50405-1577590.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "13aa3c88b8cedb565ced95d03dcd6b6ce7d1f4035128d27c6468c603e0521f99";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.113.50405-1577590.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "a054d58a5b3469ec62da54ca43269ac7c3544f30ab5ccaedb0f5a56bea1bd5cc";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.113.50405-1577590.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "03004f0f5bd5bfb7f921725ed07b3e716587fcb2951561cb13eac37ba5319080";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.113.50405-1577590.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "8283be30e81a70188a9614456ce6e2d85939499085f1d2ee6cfe756b1d7ed112";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "b72f212e647c99ee0953f35c7a442418717aafbd826e701de2addf7c2e6df80b";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "a9daac7b216a62c7e8e19a41c2e497f35b2bc83e7f5a726a8d241363c8311563";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "222aafac3841a22aaac3723b6b7d408a134d900329c5918fdbd8d5d9626dd1a5";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "b0ba647a2b11a64f2bb69630cd8b030077f104131ebb8235488bd271f9c11ad6";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "bfb21d17652e24675e5c224d8466bf8e9d5a093885dff8e86aabfaad22d71cfc";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "53a5a439851c8bf1f8833acf4e93980dfb25c9c9abc3f9a5051d939cd6777053";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "dd2a8dce6ffcafe88337d551c95f6b2e37ad8ee83b278c47994155ee58a9c6d2";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "9c3f3d664d26b74038e3f38c9099d285be8b74174a4ca0aeb22bcc4eb3f248af";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "77aef43b1a04953c69acf16e1f5d672748581e0fb206b542b254363454b71d1a";
    });

    libllvm15_0_50405-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50405-amdgpu_15.0.50405-1577590.22.04_amd64.deb";
      name = "libllvm15_0_50405-amdgpu";
      sha256 =
        "403e139f3abaa937979dc6a8adac38f0f8e7f4ea325a19ff5ec073b4ef07095b";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "c6529243a569d08db971bd63d9f4e46ba64655012e97aca64169bfbe762b187f";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "fa796caa9f1f2925456963daf05334022bb5e3231061a21830e749bcdb64d729";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "14c71448e6686e9d3379e6b753f9ecee54f85b5ce0e84f70ba4b6266d9c85685";
    });

    llvm-amdgpu-15_0_50405 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50405";
      sha256 =
        "827e750859a4bf4d334caaa8ce0212b86b4757082fde17b8789da4a8c8fcfe62";
    });

    llvm-amdgpu-15_0_50405-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405-dev_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50405-dev";
      sha256 =
        "6a4c92d09741766f03b5a83bfd5c857860ea7781afe38e3677b970edeebfed55";
    });

    llvm-amdgpu-15_0_50405-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405-runtime_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu-15_0_50405-runtime";
      sha256 =
        "52507ff4cb78a53839aaf542b69c0d69d5db8643aa54595a9e8fbcca1c090aa8";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "4cbffe4dae5a393eba604a28f355d8199177704c904b21134c804934b8e23bbf";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50405-1577590.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "a16b05277d40a8ee6bee9b27a2252546c5d95b87c88516e5b1bd549d7108f050";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "066cd7cf590adcc680cf948d76dada16f0e326d5dd7764f75a2755b918620803";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "89ec35b051aa4d72045a2a2a1fd5b815e1d7ab1ffd5d89463cd45f89d20a373f";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "863222f50247a0d630aae95bd1cf046ff41dfd53232535b5de41a3f3867b4c83";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_22.3.0.50405-1577590.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "29da6b133c90dfdd369c67f36529ff02801c01d659b167d5f6df350db7a67a4b";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_22.40-1577631.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "f4cac32892469e6eb064ddc63b92ee38f351d605ad36119d4fe3b07dc2414cde";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_22.40-1577631.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "5182946c42933595f10711556563dd24602ae5493a74e935e58eadfddcbf558d";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_22.40-1577631.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "c377f8c505cee622537331908eee2ac2316611bfaf20b14af1e3f3ec6604a5e9";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50405-1577590.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "c814bcc68361e3c858b6a32b9c8ed643369a4c35b73ae329089e53b3c681724c";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_22.40-1577631.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "9b1a19a769cfcd6f4a80e1281bb1d45a49e1fa2f2f12c6672fe014a42523bbd1";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_22.40-1577631.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "226b6655d437e9acfc21826b52e4c07f7f8302a2c177859b1b903faed0d8500b";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_22.40-1577631.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "6c56bb079bb09b32e3008911069cc7fe1054e52fc57d445bc5d56e618adedb0f";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_22.40-1577631.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "36bfe5bed22ef6c4c5c054410663ffa6651d6740cdc92ac9fc7d07674f162bd4";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.29-1577631.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "a597ac10158fa40b49fa254faab3e78dda81ddc97d55211e2dc89628691a0d0d";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_22.40-1577631.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "e60101af8608b030fe8aa200438633ccfe9fb5553a41806114665313438ddafd";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1577631.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "fa03586eee7214f706c7e0b0c1eae52c3f2aa8edc831346509163aaf44730b50";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_22.40-1577631.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "5cd743c0ed1fbd447201e389e1976ce01eb648220b0f7a7b648303eebd629ad4";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_22.40-1577631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "d28c781956863f64a588a87c980cbcbd7af951c0cf6d739e244dbac5b4e5dc17";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_22.40-1577631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "f04b30f354171bd75950cdbddd4a99297552f58bd9dbbbaa11ba2de8e9d4dc70";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_22.40-1577631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "d16ac7965519136d35e3748243b519adc8b27096632adfa551678fb30f87ebc4";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_22.40-1577631.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "44d28c6dc63f8523c16685f52967d982ecdaa726aa952a07a5cc4317c168ea6a";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_22.40-1577631.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "f3599795ff9de1878e0a45d2ac31cc6f831e0893e87d7ec4b8f98b5e4f367966";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_22.40-1577631.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "9d602e62e3222fd405ff4573c18cfbaaaf1bc19ccb08f2fdd7ee8da7743f8ce5";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_22.40-1577631.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "24d9a1376efe33ce0b3ffecc827b2263fcdd6cf53bfdb9f2a626d11c4198f7b9";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_22.40-1577631.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "83626be30452abd7d3e1fce413d618b5b68e874e2a85d5ab370dd90b7fcd9373";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_22.40-1577631.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "96a0b1d7cb138afb4ccd6a245b0f9ae9de3121e3019191d38584a6e166a1fee8";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_22.40-1577631.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "890e104a769e525bce7af8f213f6fb33dc020045c2849dc0c7b931c6badd6a0a";
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
      libllvm15_0_50405-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50405
      llvm-amdgpu-15_0_50405-dev
      llvm-amdgpu-15_0_50405-runtime
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
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.4.50405-1577590.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "edbcca28cee851b0a99768fe2d226c298fbef87348f2edf6d3940c0ff96188be";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "07347e5c2d32fda267b4a9863a3cf3740b8cbe1124362eceac3b485981677f70";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "a8a55f04e515eaa383d08a19aea29852e3c9a087cf5e0869166f8aa235954001";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_5.18.13.50405-1577590.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "30f6d29a0ef53a6905a08412b0837339c2398cace7fab7edf6dfab60ac7d631f";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.4-1577590.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "7a84f31e196fe4bece810f24ad80b3d9a1c93dc9d276ca56bd6b4e3dac38d8f0";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.4.50405-1577590.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "f7cd6f46e7286757795ca44c1633148ec128bd9892abd982467bd43c4efbbded";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.113.50405-1577590.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "b22f8690dfb12898ec5c528043574578fec3db2275f496dee848a878feaf81ae";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50405-1577590.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "71a4a7fd47473124a3520a241934552b374ebfa4957970d6b19d50d60344723d";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.113.50405-1577590.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "c927e59c734b52b1fb02494276f6dba9d704f3abe28788d41bc732bace4672b8";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.113.50405-1577590.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "30a611ea3ee9b2cce9e1bd61001db7379d2e9d000fce3b26e891c60a28dc748e";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.113.50405-1577590.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "d777273f83ee45cb59ea80c2da21f98ce1f0addcd8ed6c97f8ce19bf4d67a69c";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.113.50405-1577590.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "e4b04b3385e474548a308c6799ac5c8bcdae21f5700a722f9098bbfd7938134a";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "f3feecec30ab2bbd140a6983b3acab200ab063c0eee80627677a523955c5fc89";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "1f632a76674c4e5b0ce2988fdbc5bfa479624d3f914bd16edfa948383477f090";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "2a5001086283387928b7d6f0bf7d34ef0674c3a2aab59a3384f8c01bf317dcea";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "4e1993852a7d0927341d611a3c4b8b2b8c0b6d2cd4dcaac251f7c8899f8a9ba7";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "5e7ea0a876dbe247b96132c814bd334e5ab716efe04529feaf1fc1cbb7957f27";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "5917a1a76ca3fa20538f89f8976e2599261873044e40bc39a62de45246137b34";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "8bb96a8b2aaeb255cb6d650c550c0e70956c1ba011dcc2991f188b52df09f6c7";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "a8c66fdd9637252c147717808e1789bfc7e6f17b428170962a451e52ec59e387";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "6861f8c588a13a353deb3c0e0dfcfe2a51a0a39560be81c0b9626664be13873c";
    });

    libllvm15_0_50405-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/libllvm15.0.50405-amdgpu_15.0.50405-1577590.22.04_i386.deb";
      name = "libllvm15_0_50405-amdgpu";
      sha256 =
        "a25fe66dd3615d10451993ae2568311c9a4fd4f8257be52f8b247c742b450a60";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "068334362efe94193f9e505469d6e94ef534ed850be0eaa4e8752900011b2999";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_22.3.0.50405-1577590.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "88d56386f5c4c04bcebbb382c0469eac6b8f49f3424ddf534fa3d390f3e579c8";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "1840e4a9a6b297f261879d5ab62dcbf3549b20ef3ea375e9af46338ebd336106";
    });

    llvm-amdgpu-15_0_50405 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50405";
      sha256 =
        "de98c5a45330f2f9de67726649936ef962bd0ee08acbbe1bb6de6fecc111c034";
    });

    llvm-amdgpu-15_0_50405-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405-dev_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50405-dev";
      sha256 =
        "ca06796f496e627d0af87b4d5d65bb42e1b80d9a8bdc2190e09d3699a64bdcb1";
    });

    llvm-amdgpu-15_0_50405-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-15.0.50405-runtime_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu-15_0_50405-runtime";
      sha256 =
        "408a354913664e04aa485021ba6954bbe94f91a3f4527248c92a37301e7eeae3";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "a7de6530e9f5407030b9618160e1d09c14995669eb2d1f2aed60855009820f59";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_15.0.50405-1577590.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "7ec57b4d054c769ddf481a94edf69fbc86617140c30a21322cc5e838837b0b62";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_22.3.0.50405-1577590.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "4295689885e3868b361a66389bb92e6fe24952ad2f31d3b95f2ad0735ad140a4";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_22.3.0.50405-1577590.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "eaad9072c84b053d27aa82758a9cd53d501b3293b00f88a6e8f89d76a08840ee";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_22.3.0.50405-1577590.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "402ab6d8816b980951ff1d001c2e75e3cc8204314bdc44b2c5ee0c1cd7fcbcb6";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_22.3.0.50405-1577590.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "196217fb6b7abf5c98966e3dd718c566fbcea64c681f1dc2c19f94ce8820e6e0";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_22.40-1577631.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "226b6655d437e9acfc21826b52e4c07f7f8302a2c177859b1b903faed0d8500b";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_22.40-1577631.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "23fb9da42e126be28bfb89d8898576a590e041531e83aeabc0916670b38b084a";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_22.40-1577631.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "c039ecb72f2712d0b47c15949dbd2a8496ef6aaefde8b903859c3db82001565b";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_22.40-1577631.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "86d73a874f50beb1a29b12cf10eeda5b36a98d4dca796f9d3424a19adf25a798";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_22.40-1577631.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "0fb6c095e1c81adf4fb7992cd928a6ff807aed74dd8c24d6be250e2ab22f53c5";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_22.40-1577631.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "77a779edf2e59e4fe9f0130360a1e987d9052b033308234d60cd0974b895381a";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_22.40-1577631.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "458c28bc43c49175a948ff0833db1fb1ec7e38523b8110cc2a56fef35eeff226";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_22.40-1577631.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "af108f668ec86e5d2346b7c7344720d575e2ae61f13e90fa3bdc7634a8a3870b";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_22.40-1577631.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "ed27e12d71b30915606bc48d400592a19cb941407b4b94f3a80b231f4c84d4c2";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_22.40-1577631.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "c67b6fee619eb7a3245e808e071f9efc1eb77eda5301d1ffcf54460494539363";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_22.40-1577631.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "593531a0a53086b4f8f93f4e3ff278bb2f02cd537de43dde7986e3d80b967c34";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.4.5/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_22.40-1577631.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "d9d46e001e9e10bad88cad4ef4043c877a4b0f7a3cf9c15332dac085d92e7990";
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
      libllvm15_0_50405-amdgpu
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-15_0_50405
      llvm-amdgpu-15_0_50405-dev
      llvm-amdgpu-15_0_50405-runtime
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
