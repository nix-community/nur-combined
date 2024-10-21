{ fetchurl }: {
  version = "6.2.3";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu/amdgpu_6.2.60203-2044426.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "bc32047d20a1391e026e1671a52156979f577c12824cc2984fa85d24a4c00436";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.2.60203-2044426.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "556965aeda865564f256778dd38b42099d89d711b3bf68520134ddf03ff31981";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "89f3ab9a4365358954584553d896a43426b830f7fae1b215e256cf0a585a1c86";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "7c98f0326d2e7ac4eeb7a273cee473448ebaede11efae077e5e97568688f2661";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "32b47561fd58632c9b8eba88bf8697e9faae92307e403881209716a1bdc26ce8";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.2-2044426.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "afd9a21ed2ab3b6ef10e95a5672f05ed60625e15c0a49f88e6bcd254a6d2b8e6";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.2.60203-2044426.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "792f7a9e24502798481a1002ba8c10ab73c35b9d87184c9bcea4cee879c7e3d7";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.2.60203-2044426.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "78de73b413f0f293543f5d7c4c74a2b18524466d49244caa62e4566ac76bad3a";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.2.60203-2044426.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "92b56fbf0250beb5b55847d196ab007e8f59c8641bc137cbe1dea9ab23f5e9ec";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.60203-2044426.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "1ad7762ab77b1802afddbb172a922bbbb1478f020a4ac834d8c535752f00da46";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "084150c2835e5f4220d1e0c4a419f5194e6d66bbee3a0b6ea355e67a09b46b62";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60203-2044426.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a1d5591a573148fa9902a8fc051a0575be496e00f89a5777789c0aec3ed21cd1";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "e0c7c342cf5cda8ba606f743482cf477099b13944e39afb95c59f159074f37ea";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "9fc57a1d1660cf18e3f74d827e9421b37e0bd540f99d3fcf7355dde7ddd98e0d";
    });

    libdrm-amdgpu-static = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm-amdgpu-static";
      sha256 =
        "9628da396abda501c400f8fd3fc96a2d5ab96d2d8ca3417a4e618828daf71331";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "09c986942963b011da931f2ad6b7026d816ae1b017814724279af5074f3213e7";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.120.60203-2044426.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "55a82e7bac3369358f4b62ba46fc9d9f2461ba9c0b60aa6640badf5d3e626907";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "031fde77cc98e29a6a8881b2543152e64e091445ad01801552c957e2e0a5555b";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "d6e6a39efe8b380cb3196575861d11ddbc8f291bfe2a4dd9a79539a23e67e399";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "9356908c2bf663e6149672fe827480c8d1b60443a55e6c6cc99afdb590565c26";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "d6b108561e4967a84895b97a503af4a177c0671a6f04e6777dbf826671fe0988";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "e5640dc318b2b79c7c4b61d8e144a1c59c06eb440c45a5f46b897446882d9e30";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "14eb0d42047ce7b37032a1787814d3248e2841e2863fe3d32bdab2e8f4ad95fa";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "a74cf5494c95b0e90ed7a0231b189bf5646dcfccaf1d36395567efb88724303d";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "71dd1f7240ca65f22f34467765274ff4ea98c6535c50db3c3636526326669268";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "215a7674e91c45c8c7f8a7ed6bf5b2312086b3951b136856937815200fcd67fd";
    });

    libllvm18_1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm18.1-amdgpu_18.1.60203-2044426.22.04_amd64.deb";
      name = "libllvm18_1-amdgpu";
      sha256 =
        "c256ecbe9aa75dfa31cf2522574c7ba8b4e86abc128cb56a7dc73dc8fc81d5a3";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "287d794dd0d967633eb7376db6d8575479eba54386e12693f19cb6983b55434f";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "6c7bd70a8571310aa888b8e1f745ceae2579b3b26d297f7a370acdc4b9afb031";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "a5384b666344b4da3302d438adadf1604d179557a5db3166a081c58d3ef1a619";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "bc7003e5eecbbcb66f3349892a8c489ecdd00f033db0a25e54379e5166eab5ff";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "d8fc4649cae465df07ac396dee1644706a49382a3f6c213264ed506c6d698c98";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "75eb8a24eccee196b5c10a720e1ba4ad9c17ece98704ea3596c240a1c4101107";
    });

    libvdpau-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.2-2044426.22.04_amd64.deb";
      name = "libvdpau-amdgpu-dev";
      sha256 =
        "09c2dbacc27707a092d363e499b29277dbce2a2f888fcae44720613c2ad3d762";
    });

    libvdpau-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.2-2044426.22.04_all.deb";
      name = "libvdpau-amdgpu-doc";
      sha256 =
        "df72a2fa32707e18a0269ca2ef3f5acf1ed00ee019d1045804b77ddd65712c71";
    });

    libvdpau1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.2-2044426.22.04_amd64.deb";
      name = "libvdpau1-amdgpu";
      sha256 =
        "14f1860b6238ce7e3380d2b34a2d9594755ee841671a59abb9a9a687ac2e8335";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "cc7682b1be9fd2589fc9e2e77b242b45ca81ef727b4e05da59d200e6c4ce5c85";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "f7f8143889a6b396e5ab991acd42edc65b918f1f71790f088f1579a26e2ad4d3";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "8ee8424bf9a15e2e68bf6b3134fa384af4c5fc71e263ff305714fff44ee857ee";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "2da048d5eeb33cfcb06aef71219c6cc780cb2ff2c06681ed643a91406c886435";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60203-2044426.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "06cad303a3341a7e827262e4ec63ef48ce25bd795a0cfc62857aaa9eb0382cb6";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "be883ecdaab9981757d1f3750cb5fd6568c57a42f73b53b7c5370f5ae27092af";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "264b10edf50f0109781121386138d74d740429b9fe97171e8b226e34070c12ad";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60203-2044426.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "372c63958511ba8b1684a3583cbde3c4797c8d74ffbf109bf3b9aabf844d56a7";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "6aafbccacd9231dc4a9be383cdf75038fead68afadfb95632d8271a07eec9a3a";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "df45c9a3f1b8fedb2f3dbdd27a86633130ac7ed953ecd6d8fb8dde950f953368";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "370b1aefeefbf2a59d74c52e47fccdfc3cceaae203019846e9fecf8612c0a5f7";
    });

    llvm-amdgpu-18_1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu-18_1";
      sha256 =
        "c9c48c90a8c5907b393979a19330ca6e3428917954605af32aea44b0a94e6dc6";
    });

    llvm-amdgpu-18_1-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1-dev_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu-18_1-dev";
      sha256 =
        "5cec1faa8fc1b1e407013dcbc2481cadea099bb9ace42e348d31bad716a44ef5";
    });

    llvm-amdgpu-18_1-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1-runtime_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu-18_1-runtime";
      sha256 =
        "db41402d0cf7a342676e5cffdb642577a8cc3c355f9078530494f5dbb8b74932";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "125eceb7528c53dc50cf96be3bab65778647d4524707daa33547ccdc079b6c24";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_18.1.60203-2044426.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "a8a26cafbe577fd7911ca9fc04e0c3058c6fe1b4b791a06c665d18e6b58f9a86";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "20fbbcff1a969cee0f21c368c914314b1462c1509778badef97419e324cbd1b4";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "08e2d758379625c22024a8e6db5516d5fb5a63d9cd0ed71ae61557b313752c11";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "2112717c3a95ea86d454b24a50cbdcae294cbb680a9b16330d1ef9e7d50b4b11";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "0328ec5e52b1dc4a274bf48b3c48c2a1600b81b7a84a0bf5635002b6f7fc96fe";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.2.0.60203-2044426.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "08e58b52b6e87cbf36a82bade2d93218f843a85d1370f9dc127412f37a4b8d8a";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_24.20-2044449.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "8266c885b726cf242aced15caa5f7b38213f193cda210f29bf3af7655424b29e";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_24.20-2044449.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "466e890749a8959935582c202e28537cabadd02f23c77fdab973d4fe569c7f81";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60203-2044426.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "937d38a9406455b0050efba9f467b74018a3da9ea2cefbd8f4632ad7dc7051b2";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_24.20-2044449.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "07d72d7f3b0b0df4b85e111a63fca0afc99688197de85423037038700dcf8ace";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.34.60203-2044426.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "9fd1d7af4d68599037ce0cc40743f9d549e0fe1f093c7647f9f2e531fa099a80";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60203-2044426.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "353450aee886a5106a868fc63f6fa3b3571f544fefe4baf5a07fddeeacfd4fd7";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_24.20-2044449.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "dc49c7fe67f6d526794900ab59ab40f8ebbf9008e727a209e14cb9ad20ec5d81";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.20-2044449.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "7be61cf824018aaf56aa834a76fe8ab3746d5cb88cc661eee759dbb727d5da6a";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_24.20-2044449.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "170c0bbf08dfd8152d75e4601187f97d5e76cc9a3d7001ee59e160f9bca8b36f";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.20-2044449.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "8d241536f37c3eaa473d4d69de72574b9b61111978e15c2ea5d1a5cecf750a9e";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.35-2044449.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "30c16bc4f83cbe376b853c1c130c0ba033008a87aaed8b53133043801cb838f0";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-2044449.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "376b7443426b899dcc62994ac7937c10b7f91cb1d9659dedbc926d9f267b607d";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.20-2044449.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "2a2cb6c0fde2ce5b200e90a2bf98fbfdbdb0ecb2751f5d398c7a0e4f5b43004c";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.20-2044449.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "5984902e6a929e7234810b3ec915d75410996b3087740a1afe4a43d438a3c229";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_24.20-2044449.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "6bf88a51db2841a7b769d56271ed31b503b80f9b7527b021ed4490275f3c925e";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_24.20-2044449.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "8ab7143665002c41fea63dead67f2d80630f77265caa1e2af949e10e8ade0974";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.20-2044449.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "a93dfd26663bb136c3ac2c817d13cbb37de05b36de0361cce7c68dfaf575e895";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.20-2044449.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "6be9ef76942a2ba89c34382d0b4bf69d279ef5e80e0c10e5d25ff722f0859d66";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.20-2044449.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "e3eb0bbb8459a6668a940458090ccf05d0db4ef50936fa17dae307dfd28f9ff0";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.20-2044449.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "fcf34f8a92773d8fe0ef0f2198d1a6d289a1393cbe585c788768728a8ac498ad";
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
      libdrm-amdgpu-static
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
      libllvm18_1-amdgpu
      libva-amdgpu-dev
      libva-amdgpu-drm2
      libva-amdgpu-glx2
      libva-amdgpu-wayland2
      libva-amdgpu-x11-2
      libva2-amdgpu
      libvdpau-amdgpu-dev
      libvdpau-amdgpu-doc
      libvdpau1-amdgpu
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
      llvm-amdgpu-18_1
      llvm-amdgpu-18_1-dev
      llvm-amdgpu-18_1-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-multimedia
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
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.2.60203-2044426.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "556965aeda865564f256778dd38b42099d89d711b3bf68520134ddf03ff31981";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "89f3ab9a4365358954584553d896a43426b830f7fae1b215e256cf0a585a1c86";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "7c98f0326d2e7ac4eeb7a273cee473448ebaede11efae077e5e97568688f2661";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.8.5.60203-2044426.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "32b47561fd58632c9b8eba88bf8697e9faae92307e403881209716a1bdc26ce8";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.2-2044426.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "afd9a21ed2ab3b6ef10e95a5672f05ed60625e15c0a49f88e6bcd254a6d2b8e6";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.2.60203-2044426.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "792f7a9e24502798481a1002ba8c10ab73c35b9d87184c9bcea4cee879c7e3d7";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "0e6c3f0291428b39aa7b1d431d82716d3c80424020815ced809f99436965eeb0";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60203-2044426.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "a1d5591a573148fa9902a8fc051a0575be496e00f89a5777789c0aec3ed21cd1";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "dbebf52f1778c771b17aaec4c43f437998d21ea1fb39620e1ee9cb2d8f2d035f";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "abff587a23cf71570fc5b264f6c6022c8b454ab3a35dc54b83b20d043715eaf4";
    });

    libdrm-amdgpu-static = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm-amdgpu-static";
      sha256 =
        "81738184e8f1001e334d34f5ce3b5c6aa57a89a58a1fed8b608782c4e2166afd";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "af7df5e30fc01ef7d17aac74f4a645a6af4bc42712463886e07cdcccedfc1a3e";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.120.60203-2044426.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "2b821893c53108c185e6cf66a1e1d7b45813631a5bcb800e81340bda23957ae9";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "2db8c0b861ca91ffee8f365742693fc8f0178a31d1e568e7e3160ff0bae24759";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "42585798a0174544cb2c53e8af90dd58306572a08a82c35223e6a76b3231fe02";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "5ce28d58cae88708460e2de294f2436120c31fdf779b29522d1019b20be97d25";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "f90ad5af648e87c9b574ca557f04e0c7cfee7fc9687c0f080c2a38593961b67c";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "24cfded0260a22e4cad0a25455fb9ee53138ac7031de0b770338a458677dae73";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "768ecfca1bd1315b20477fbdbb20516aa9337f134532faf6877ab2860b3be0d6";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "412e71aa1ea1a42c6cb0d3718a416cec0fcde83f0e9df0c4d3d1b5fe509938d8";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "073df766ebe1cd08b0c3ed61536a467e1efb405a6409185870e8aa3848b5f900";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "bceacc10568b7855d68a6b7c49fbc05258b480a51c4a00591e2ff63a7ab96abb";
    });

    libllvm18_1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm18.1-amdgpu_18.1.60203-2044426.22.04_i386.deb";
      name = "libllvm18_1-amdgpu";
      sha256 =
        "f3d145f9726dd799eea516af459fd0cd4d366ad8a755c20a4c898baf3a323cb5";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "9af254abb282ab56b22b7fc6e3888b3011e4e6aa6f780b18ec74000ed9438f66";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "826561d3ef8a087a3efda9c40d8eaef241830a40c2b15c5da1a60694ad1a4a75";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "6fe36093a2e5c8754a0baa135c940a9d34cfa70a3b7831f6eead9238b2a73cd6";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "640d55da90b53ea1e8fe9e80fa751e6264dab07c929b47ef9cbe1cae8a423f27";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "a45fef6f0fe6d257c03a484e495a43412824343fe6c2b1e328c90535a1595c94";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60203-2044426.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "c98f4fb5f3765ba908ff5d19f4a956e1775e6ab03c2f88192b42a9991bebe10e";
    });

    libvdpau-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.2-2044426.22.04_i386.deb";
      name = "libvdpau-amdgpu-dev";
      sha256 =
        "bf3016ecf3a798435ff914759f9f4a86a61840eebc734f336890b6ac4eec612e";
    });

    libvdpau-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.2-2044426.22.04_all.deb";
      name = "libvdpau-amdgpu-doc";
      sha256 =
        "df72a2fa32707e18a0269ca2ef3f5acf1ed00ee019d1045804b77ddd65712c71";
    });

    libvdpau1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.2-2044426.22.04_i386.deb";
      name = "libvdpau1-amdgpu";
      sha256 =
        "7b0bb4879332db0c518727b620f1afd463c1aa5237000695582080ebe4a5ce17";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "aabe2a052fad8485278090e49ebe06aa2bd2b3788b05b1235f016dfee0daf7e3";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "f981bec2e1aa82ceeefcb58f292d180884de32c08ec68a1a6b24a100fa021360";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "4738cde92800cf9627cbbe32dd5b6de0abf88e0c6d018d46c6cf984ad6f7412d";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "36bf91d9ab33038c1290ee56399ff0e0a843923bdab2aff3e4824241dab52e3f";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60203-2044426.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "06cad303a3341a7e827262e4ec63ef48ce25bd795a0cfc62857aaa9eb0382cb6";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "4c1460ff25efe9d2372c4183a649e31875644f767e0060cc8e116516d37eef1d";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "7c5b79efea0930af2f54add699698d08c6b31a97324014d28ddcd1f75129baf1";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60203-2044426.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "624eef50e612740258f6ff0461981229cb9a1934ed74c35443dacad711140cf5";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "b64adb8ceb1006a8ba236954e19df5c7254bfdc53cd5b5709d37baa24306e15b";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.2.0.60203-2044426.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "579abb96c29524ea2d310920c79db1c61ae1ae76644fa7cee3bada676356b9c4";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "3afd5a8765f8eeca85826aa87715e51cebbe4a0632ed0ee5d9330144b9fffd4a";
    });

    llvm-amdgpu-18_1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu-18_1";
      sha256 =
        "25a94b9cab49cc90697732ccab281713bdcbbfbbb77344142d38d8210a2910e4";
    });

    llvm-amdgpu-18_1-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1-dev_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu-18_1-dev";
      sha256 =
        "353335e4516984de040ce5d62f226ff271d07ff8fd06cb953701e8504fd96b0b";
    });

    llvm-amdgpu-18_1-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-18.1-runtime_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu-18_1-runtime";
      sha256 =
        "d1c461b15dc7712e7496498a5d3029d28eb421794304d25f406ffff9b807e015";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "892e66393dade44061b43aa6c928b4ca2ddca684b3b22fe3ab366eb97273f462";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_18.1.60203-2044426.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "dc94c78503d2c8edf5ff4003022cf4c1d0b6df0655b8692055493a226f79eb92";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.2.0.60203-2044426.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "83250728b96d0a745d1d18d9466bcf9a6e8aac3f52231d437c6d9ee4f3192d44";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_24.2.0.60203-2044426.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "bd5635dba9ef6416cf6ad2a3bf6857cc772ce841db47af0a69fe36f034573fea";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.2.0.60203-2044426.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "3b24ebd138e20b2901351e9caa65c8b030afa014ca453cb9fbcc4a7e0862546a";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.2.0.60203-2044426.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "bad71247f28263142c74b81fdf08ee31f3cebc42a47d62c3a9da0ddd5726b441";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60203-2044426.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "73c0b910e541f7433ba2ede99c3f6721911bf382526652e8c13b6e6b0d313ad3";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.34.60203-2044426.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "9fd1d7af4d68599037ce0cc40743f9d549e0fe1f093c7647f9f2e531fa099a80";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.20-2044449.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "7be61cf824018aaf56aa834a76fe8ab3746d5cb88cc661eee759dbb727d5da6a";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.20-2044449.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "96ac474ccc8df033e8c2b77f262b2be206cf93167ed67045f1227adb7f006d5f";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.20-2044449.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "36cfdcddad0356411c9300407d7b4a3e380ee3d5fbdc7f2f7ba6741dfa696908";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.20-2044449.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "6b778c8065a6e1f9a4dfa6b421ddaef57f1e2265b6fb026a300e11dc3321c4f9";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.20-2044449.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "030a6b176f988c04a410925105f537860af8782086252a6b7f73a52666e60868";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.20-2044449.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "2539d83d5fea6210d42a07928b30254238838d7eeb91c37af9ac7904d20672b6";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.20-2044449.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "9b6ecc425a8884086afadb6f8c62b23621fa9e593f342fa331bc005ff07410fc";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.2.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.20-2044449.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "f4a1c905417de7261f56610307b2d3e5cb4c97719b0e16f2c39b8c9af30b3293";
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
      libdrm-amdgpu-static
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
      libllvm18_1-amdgpu
      libva-amdgpu-dev
      libva-amdgpu-drm2
      libva-amdgpu-glx2
      libva-amdgpu-wayland2
      libva-amdgpu-x11-2
      libva2-amdgpu
      libvdpau-amdgpu-dev
      libvdpau-amdgpu-doc
      libvdpau1-amdgpu
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
      llvm-amdgpu-18_1
      llvm-amdgpu-18_1-dev
      llvm-amdgpu-18_1-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-multimedia
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
