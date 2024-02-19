{ fetchurl }: {
  version = "6.0.2";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu/amdgpu_6.0.60002-1718217.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "73b6e7ec640b1ad2a0a3db0841e5c26c22df5a2d4b3ab08db2affd94092c023d";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.0.60002-1718217.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "18e91d6560044ed266b84434167abb3db1049cd4ce5833725a6a239c6ee0eb0b";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "7d89ba65c9c3e36b425ae7c68fefb3270b01f7cce334f16e6e24e6f9e535a3a0";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "e811cbbd00c2d765ce9bf6d152297147c8a5fd3d45cf527d1470bf6eb17c29e5";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "cb793ed1a55b9b44100adc32e3b4d19062852bb70d10c7835edcc091550c424d";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.0-1718217.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "5be12463d523b2b01f4d9060295a8069b30085e8546a4ab051522c908a25eb60";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.0.60002-1718217.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "30a022d7a7520211a00844e6c73a6307ac3d1a69a7a78d278da6355330411051";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.0.60002-1718217.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "d841bf058b357b8e054dc9d1aa91f04f96f021efe814f4b95ee057dccd7b2c00";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.0.60002-1718217.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "5eb68e921dabb24f719faf3cf95adbf6c89249efc4879d7ada89a2a926f58b52";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.60002-1718217.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "2a1cb8949099d6687100f98463dac34da59735f2cd430dd500a6543c640f7dd1";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.116.60002-1718217.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "3bda8ecb552e14ac35479335431da5674ed09e20988b0b5464d887fe7d020633";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60002-1718217.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a27686d61bd88178033b723be726721960be278bb1679b1a92f76a88c1a8c9e9";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.116.60002-1718217.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "ca347a6dcbf7b1fd97243728a143639050bd7f13698eafaf473bff043d554ae2";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.116.60002-1718217.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "f07bba3a9638aac62bc805860e0fb8f13b35e886312dad7928e6486460bc30a0";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.116.60002-1718217.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "ef08a5f46e6e9e00104e3f08dba4bca3055403b2fb1a5c120747265d0cb106db";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.116.60002-1718217.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "345787897d7fb15286a3381df9d0ef5a70ba6fc7263d9f05dbcdf698983b612c";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "ca96b3962431afcf34355c20b4f0de48c3858b3248bb30c9da8f0124ca803476";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "ba822f291a5469804739d7d13be491716cc9c4fe08bc91595b732385f5c19179";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "b601ef8de009263699dcb679f1c88b00ed984b32205b55cf1a2af3247d329bfc";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "fe626089fc969a2ffeaccb8c7eb9604c396c12e3562ea008d8eb2b48e35c21c2";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "8c5d737bded4bdb468591c887749661209f1a306d3d5d45abf0f9f580b066461";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "91cc4dcdb9913468045e59dc6d7a24cde869978da9d4ddb1ab4d2845eb4ae73a";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "3828b5b48729d461da9f46847e0dc684afa7ab0a18962661fb3b7708a6986eac";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "a0d89c2bdac6a6b92f96660457502285b962e38eef9cdf5350fa735b6feaa6c3";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "a229723649d51c97755817d05229514f8c411f748a14a84a1b4f7e3248454589";
    });

    libllvm17_0_60002-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0.60002-amdgpu_17.0.60002-1718217.22.04_amd64.deb";
      name = "libllvm17_0_60002-amdgpu";
      sha256 =
        "e78fc2b20bea62531edc1ec3cf7a15fcc4ebde2b01e0763fd659de86305a3b56";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "662c4d684f56a51a7ffd29c39017cab9742ad38a4c123d1f563a745ac7939e86";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "84844a1d8f9f30da37f0308bfc92655383745b83725026c12154445498ec9363";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "294602af52d836f81f508e98f5a19035595dd8212f136f8ffa929e06c0fc18b9";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "20b6020d1cc332fdb23728d6401ed2c0909e3612a3b7f6cdf54f5a9069ba2b28";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "7b5bc0d201493cf0b874d919d1b73e9aab7bc742fe067db3e11315ff90bc6fc9";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "4c4c2892f22826d8bd501efc97214a586f44071d7e00d1c34a11828f5d6f8417";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "67e95a4aedccc13a9a8867b33913dd00ad9a5ee44ad92606f5e677917dabe2bd";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "c2df840bcd9e5fd11cea9a2d8d2fb0b17e3c7d1787ac344807f3207af739842a";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "9acb418af96688d6c2a198f8e2af57bfc617d2b09488040db97f12ddd3b00733";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "eef780d2d6b05a8bc795fcf91eee79322475775733c827935574ea98919f2773";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60002-1718217.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "61b698f5bb73c4c3e56a8441f625d5c532a5f6eab5119a87874639e73a58bcdd";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "63655f710208cebfea58c9b9435525bb6a789006310f8e80173fa765a69fbf2b";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "23ce6a72c87e443e05d5a9e77a74d88504b7d6e0b021e4cac0aa05f2f82d4530";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60002-1718217.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "aef7721ee301b29ac04363f07bceef720e7a6327c08ee798ba5f15f8e45c5ad3";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "7381279a606f7eab4b7003685fa87c81e3123ad571e9d2f2a53fb15076041d3f";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "a788e48b9469d91a3879ddc67c87900fbef6699a4b13f62ca6e316c29e505061";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "04412e32375e258b16d1c142d7041042bb5bb512f5247ffce305f4af72052cc9";
    });

    llvm-amdgpu-17_0_60002 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60002";
      sha256 =
        "8b92e4197f537f0a2bb456f6095d86067bb079d5c7cbc7d6d7cd23b51ad421fe";
    });

    llvm-amdgpu-17_0_60002-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002-dev_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60002-dev";
      sha256 =
        "7f7b50ff92662600dd9d494f681898ee4cb9752482e686e529b0755f5a50b743";
    });

    llvm-amdgpu-17_0_60002-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002-runtime_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60002-runtime";
      sha256 =
        "0a4a8871ca0d0260fe178296fdac4e8c557dff1bbfac554cc3aab819ec1482af";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "63e48a1a87f543e2f2b0c2be94295c4a5394312c6cc73868e30257d0ecd6b727";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60002-1718217.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "57aa1b2ff1b28687ed81528ad3f5325ca4b40d6240f3f81d3219272587e7c35a";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "a079d83586c7a1bb4076179822da4306da82ffa024914e7477346cd4b4cbf07e";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "db120952158909f23b852109d69063fc0fee6bceeddababef4756d9057ef68b9";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "344f6d59acd4be0b61c762aaa5871483a6df76aa11753e16b0abd4188a858c3b";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "e0c3301c0e5448f0a2e8e7d856da5a930709ca03201e7643b9776d5fa7483517";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "6fe1338191b8e5d691af616a5787a1219cecdc011cf6071f680696b560d90eee";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.3.0.60002-1718217.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "7b681e76e1b57cc8e5951d4abee474cd75e88845b0686bb15231af9efeb42909";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.40-1718238.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "8525abfab00c3fc3b163dcb42ad75be97439040fa56cf195bb23787d7d3e84fa";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.40-1718238.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "e7b8cdc0d4394ba6f629af0a59ad3e4c65ff5ec6c4f5e511be1f6271fcf56f6b";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60002-1718217.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "df7723090aed5a5e4628459fcf91b27a6902391659f5c1283ac32e54be83f93a";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.40-1718238.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "3487a9336fa59c9f14a58a7473f04cf1afc78a90bce50df3cc1ce55a391cea22";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60002-1718217.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "cca30edfe9ab833b9daf57b59650ffda8f55a67891b71deaf9e55b2f3aafd542";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60002-1718217.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "b7954df2f111e0a2e445d64c1a227ac011a3ae92572432e7f05841e89ca75d12";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.40-1718238.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "b82e839868254057d29da3a0779085c8f6690a1df0c25f265fc59a7cf01fa240";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.40-1718238.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "4b11488b3cdbb2c1c4e2b22ce10a485330efb173271b73f8e8486bb753f248d4";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.40-1718238.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "939ffaab5ec651a2c704280d9345df015b4af743e8abbecac1b4f72c62ac8966";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.40-1718238.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "47bf7cbdab978c5bef794a16990265e69e9bdf7fa9adfc15d4b87836b3aea688";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.33-1718238.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "233c3f678b3d0c85d20762f3d32b0a965f4ae6722ae54a956329aa9b57da346e";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1718238.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "c48915bd0a4e64f30c60edfd58a1ce34e2843f71c981ae3fb13a6af7f54720bb";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.40-1718238.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "c698bd41fcdf01dbb94cec93110f90ab03a42fc5cca181b9541b3985928d0b1b";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.40-1718238.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "fa084416959a49cc4a3b1cead7d44f1a4c0da29695878e2e55b3c3ade95f838c";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.40-1718238.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "ae2d3f855d5d0e0c0962264d81bd5fec5d093f487934771d3a817ed0e9e8c123";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.40-1718238.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "15faee904ab0bf3c2ad9d20759c503dff08fd7ee0a823dd7af9df8fe6b47d674";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.40-1718238.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "2541804ee3e349f9467857f6ed47b3e10d3c2136ad493b127eae309ca5469f3f";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.40-1718238.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "47c029a34f0248be1dc2f89cd22dd6a5a133aa121ff3ea8aa41468d78f439308";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.40-1718238.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "5c536067d26522f72a4491461954c9c5a064cc62b96c46e6eda0ba1acb1d8191";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.40-1718238.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "5daacfbe31b46458fad74edc553e719a3ffb8011906e8a2f50d7c8dd1a921921";
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
      libllvm17_0_60002-amdgpu
      libva-amdgpu-dev
      libva-amdgpu-drm2
      libva-amdgpu-glx2
      libva-amdgpu-wayland2
      libva-amdgpu-x11-2
      libva2-amdgpu
      libwayland-amdgpu-bin
      libwayland-amdgpu-client0
      libwayland-amdgpu-cursor0
      libwayland-amdgpu-dev
      libwayland-amdgpu-doc
      libwayland-amdgpu-egl-backend-dev
      libwayland-amdgpu-egl1
      libwayland-amdgpu-server0
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-17_0_60002
      llvm-amdgpu-17_0_60002-dev
      llvm-amdgpu-17_0_60002-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-multimedia
      mesa-amdgpu-multimedia-devel
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      smi-lib-amdgpu
      smi-lib-amdgpu-dev
      va-amdgpu-driver-all
      vulkan-amdgpu
      wayland-protocols-amdgpu
      xserver-xorg-amdgpu-video-amdgpu
      amdgpu-pro
      amdgpu-pro-core
      amdgpu-pro-lib32
      amdgpu-pro-oglp
      amf-amdgpu-pro
      libamdenc-amdgpu-pro
      libegl1-amdgpu-pro-oglp
      libgl1-amdgpu-pro-oglp-dri
      libgl1-amdgpu-pro-oglp-ext
      libgl1-amdgpu-pro-oglp-gbm
      libgl1-amdgpu-pro-oglp-glx
      libgles1-amdgpu-pro-oglp
      libgles2-amdgpu-pro-oglp
      vulkan-amdgpu-pro
    ];
  };
  bit32 = rec {
    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.0.60002-1718217.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "18e91d6560044ed266b84434167abb3db1049cd4ce5833725a6a239c6ee0eb0b";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "7d89ba65c9c3e36b425ae7c68fefb3270b01f7cce334f16e6e24e6f9e535a3a0";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "e811cbbd00c2d765ce9bf6d152297147c8a5fd3d45cf527d1470bf6eb17c29e5";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.3.6.60002-1718217.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "cb793ed1a55b9b44100adc32e3b4d19062852bb70d10c7835edcc091550c424d";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.0-1718217.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "5be12463d523b2b01f4d9060295a8069b30085e8546a4ab051522c908a25eb60";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.0.60002-1718217.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "30a022d7a7520211a00844e6c73a6307ac3d1a69a7a78d278da6355330411051";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.116.60002-1718217.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "487a967c8645c813e652e34921f92b2ca403435570c083e61bf0fb4b012b5c24";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60002-1718217.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a27686d61bd88178033b723be726721960be278bb1679b1a92f76a88c1a8c9e9";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.116.60002-1718217.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "11852d6c57ed23cc3db886d41168333d2759a08141d05ad75fdfa97b5702e900";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.116.60002-1718217.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "bd074f3c4be22e030ede05fd62a525ce86ba4a704ecc152dd62cf16002431c8b";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.116.60002-1718217.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "a41f6f64d971be3dd0b19525bbaa1a85b1d1d8cce24f6ab0a022efaf4e075f2f";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.116.60002-1718217.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "c62fdb6477ad35a7197262dc45be9ef0a6adca901b7e1ee1707056a1fd448dff";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "5f13a07e345b552f22e755f061e0c1190af13d006e4d57b8436a7ba807f6dc28";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "77009520b9b89cb8c94d779bd5c8053af7e35ea100d83864c784782bf8f87fdd";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "3b217632946373e5fb1c4c43c83c3aceb80829af563ea26761f7f9b4189839c9";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "2ae17403e1d9b4ee273c8463816ec521adeeb357fca739a53c83bf2a345b347f";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "6308a436aaef0d3019da1d86ee45646b0321f07afa4c8e3d9db20551f6b5b1c8";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "066fddeda5ddbbae3e519d94530f0a9c68b483c40d911c00ab23bd60e241a69b";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "958f5e81e6a9392dd62806733348ddb57b68bb227b5b00d7b6faff1458fb3d4d";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "06d324680352f9471f4b7b03c7877583841881973bc87cd8324c1caed663885d";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "07b061b0653cf4837c0361270d8de7c4c6e178b56b68db0e3f9838af64c48b6b";
    });

    libllvm17_0_60002-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0.60002-amdgpu_17.0.60002-1718217.22.04_i386.deb";
      name = "libllvm17_0_60002-amdgpu";
      sha256 =
        "d932687e6eb6525d276c1f29b4f759018a8b117516813a36de303722897ac73e";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "6d669efed26751c9d58b150db9bb207bd6fd8e5027b75a973c3a7a86f9b8aa7b";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "cf118e0ee2df32bc8c141a44a2590defba2b81b83b926fe17c90bc616ed186a8";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "1d0c33a6de73b518d546a52b3ae66e3a540b37da1672c2828f7f64ec67d13cce";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "34cbc871f9a8d0bfda9c1e608c2cbcbfd718d9ae4620a688cdb56b160a8fd0be";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "cd6c2cc55d096f13b713337f56ad8a0b3c7200fb0f83db1eabd68166ccb58edc";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60002-1718217.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "1a5e28056cf29752dc4c10b22faa69470cf6f2eac46efdffb8b700f30a973124";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "2e819834074de42632ee9c80915dbd2f954ae00e4829c0e73ebcb88e7981e110";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "5e72704220644019fefdd3cea7b9366433ec74c44c688b9a6bafa9a7b4d9ada9";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "397cf52a9180e0f00d3fac632c218c823f799fb391f513987192f790bbbc0e89";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "808a3e06d18215d4d09a952002c836bc36e816a63aeea19fd48ffa59a1311ea4";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60002-1718217.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "61b698f5bb73c4c3e56a8441f625d5c532a5f6eab5119a87874639e73a58bcdd";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "42417724de38252fe30eb5f6c4eb9b3bae985c1f116117047f13cf57907b265c";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "763f7e5852f5ceb51f9105f43ac3cf02df096a95d4109f31d9ded56ae99bfab4";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60002-1718217.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "e40cee44f8e753e4bef887290b0d2c65ddc3172283535214ecd56c6c33681140";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "14b6a4e588a55c2ac4d67fb8b9a726e810400f0909f81eecf26c64fd5da5163d";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.3.0.60002-1718217.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "86681f134cb1753f619ec58956497c85e4a9c5747524f5a578b5080d62414dd1";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "c7ac7a36c39eaaaccf8b61fe7d1e5a1f703679a5136a285f9a2daf7033f7f30b";
    });

    llvm-amdgpu-17_0_60002 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60002";
      sha256 =
        "ee9faaa483009ca32e8e49ea9ad68e41d0bd5682b3d8d37e85cf5657c578bbb6";
    });

    llvm-amdgpu-17_0_60002-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002-dev_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60002-dev";
      sha256 =
        "e87d576fb4938cd7bd6bb23bc040a173d9088b8b43324a1409d8e59374d45e6f";
    });

    llvm-amdgpu-17_0_60002-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60002-runtime_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60002-runtime";
      sha256 =
        "c923a36a1a2a585c2aef4a7a04dd03dd774082c26c44cf68ccc3aedf734a7f95";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "2639a0df8c26eddae41dd455c731b08e0b876da4445a5d0c5e1eaf92c99c8093";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60002-1718217.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "cc13a795b1c587f0209cac18a2f941046a601ce4a4cabbd1a5718aa99b9e8f2d";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "d26fb8c0bdb6a418687445bb40310d3718863ade89a663ff562b2fd4a95244ea";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "48e1c78ed592c2b37ae9dcc0be90ec3be48a44ef6168a0afbc4fa3fbca95af68";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "e83bf5d38cfaadce6be91cccef03d68915a54db66f3ac07e19d93a5411fa75a4";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "43bdeb1dcf3457a4d67c3632e6c0c5bc039052b0c6e788668080e5084fb22351";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "8192919c633e879ed9b878cb7510d5e4efb3924e841f4d70df6c14649b8f7c14";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.3.0.60002-1718217.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "e0b4b4af26979d4923330a20a764ab17e5edd096c3ddc4e6a234a86e0e05998c";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60002-1718217.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "09717a87ce2a29d5dbb91887b7c648622d4430a176f8caeba0ba0e5c34408dcb";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60002-1718217.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "cca30edfe9ab833b9daf57b59650ffda8f55a67891b71deaf9e55b2f3aafd542";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.40-1718238.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "4b11488b3cdbb2c1c4e2b22ce10a485330efb173271b73f8e8486bb753f248d4";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.40-1718238.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "f95a706d1c1ed6b41c53b931ee69a3d17052d9b63c54ce61cba3987bc6a109c9";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.40-1718238.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "1d26df3f31dace0ff41705d24eaa5b09b881128c33cc02aaff52826b7a0692bb";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.40-1718238.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "6138e950654e389d4ca5c4c974e181c52e9c5c35efd94432a1380000b372452b";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.40-1718238.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "e7d180f40204419d54654d32e0f902b13712be8411fbdc5c87ab1ca0150d9cbd";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.40-1718238.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "b6790f62ca68130046c7a10ae0b96a1b190a381760c660748fa0299823ea00f4";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.40-1718238.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "c0a8d93fdb166e9746ef1a64bc36e3225d1459c16f158a18da3d432196db4d22";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.40-1718238.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "1c8a84fcb6d92d65895901870e5032075f0dbcc0aee5c4cd133b8f29738d1e9f";
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
      libllvm17_0_60002-amdgpu
      libva-amdgpu-dev
      libva-amdgpu-drm2
      libva-amdgpu-glx2
      libva-amdgpu-wayland2
      libva-amdgpu-x11-2
      libva2-amdgpu
      libwayland-amdgpu-bin
      libwayland-amdgpu-client0
      libwayland-amdgpu-cursor0
      libwayland-amdgpu-dev
      libwayland-amdgpu-doc
      libwayland-amdgpu-egl-backend-dev
      libwayland-amdgpu-egl1
      libwayland-amdgpu-server0
      libxatracker-amdgpu-dev
      libxatracker2-amdgpu
      llvm-amdgpu
      llvm-amdgpu-17_0_60002
      llvm-amdgpu-17_0_60002-dev
      llvm-amdgpu-17_0_60002-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-multimedia
      mesa-amdgpu-multimedia-devel
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      va-amdgpu-driver-all
      wayland-protocols-amdgpu
      amdgpu-pro-core
      amdgpu-pro-oglp
      libegl1-amdgpu-pro-oglp
      libgl1-amdgpu-pro-oglp-dri
      libgl1-amdgpu-pro-oglp-glx
      libgles1-amdgpu-pro-oglp
      libgles2-amdgpu-pro-oglp
      vulkan-amdgpu-pro
    ];
  };
}
