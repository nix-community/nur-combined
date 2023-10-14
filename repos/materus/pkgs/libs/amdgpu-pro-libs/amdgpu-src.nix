{ fetchurl }: {
  version = "5.7.1";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu/amdgpu_5.7.50701-1664922.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "f4bcecb0d54c3c7afc331c83a4537b189f44f5252bfd1f299b515f98e3c50166";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50701-1664922.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "959d31d673c6c632e8816fecf5a0bc6bc342cfefdbb9655cb1727cb4d6356e0c";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "b06d61c2a83e9bfab552c170258c23b96a1453d2dc5d76d0462f9a2221b0e050";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "b8360086fa9670d992c14a0746aa6152bfe4ec828b09f77afb2b66f9a55f2d2c";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "139f22b2a0cdf83b0307245bdf400723e97b1426cf880feef04a950fb18873bf";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1664922.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "2560b85b3cedb8a9cdd4b230c724dd82957f0e4042985ea0fb5ffbe09882f361";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50701-1664922.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "f9dfd52ab86178168f0d934ced4d7cb220d5cecf0f416eba166c3cb26c8ed0c2";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.7.50701-1664922.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "1fe9e3b41d6c32703c6e7b89726339e47dd3ee4112f0df5d6a8017469d2a0786";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.7.50701-1664922.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "327b08b1cc3af9c3c396581396d4ddb6ee35f9b8a5c17d6a6c2815e5708cf2c9";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50701-1664922.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "242318973ada53b50674fcba27221a8d90378a11080ea7d8e5b6703b49000b30";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50701-1664922.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "ea0ffb3e9c27aaaa06c327bb60b85864bf0e3cff1c081bdb1e09d30a88f3716e";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50701-1664922.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "d8430ddfa127d3137cb7e13b011589d3540bdc9ff9fe6292398ccbda17a8182c";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50701-1664922.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "85c4b4421dd2fe36bb708687b2aca92184f1b899efc1fb74b27cbcc52ef94c50";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50701-1664922.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "75de38e5456c7e755f0c69dddd57840a557f9d5965a00117fec50c20ded8c4d3";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50701-1664922.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "629157523de81afed3b60970a996b5d7371d4af5d98d7f5174f9c1389d259dd5";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50701-1664922.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "9a2b4e84fa94e4dc3d2baf4495c14a2ef4e3df4ff3d6a6b544a8204f4f724a92";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "557e66289810a8fdcaaf618a49208267bffe3476f129ffebbee067d239a7a1c6";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "65096c8aff295d8718c27ad6c0b198633bafacf949c02f620c76b4c03cc7b25b";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "563d71cc8c994e4e3affc2317be4aefcda7d60ef27e1b8a1ebb16105a8076a36";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "8ec50cd403f1343a1bfce0db6fc2ba28bba4bfc71506cd6220a288e85f919113";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "74f3119fa5d5f3bdb5564eae5ea0d23f8f2732f46ab2fb8e2715dac24422c20c";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "6f8af14b5c3f4e4c09ad3cc6ec17b70c19a91e87fc2a06684e3599d6392f674e";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "f3caea3f6d29e39712ef5cdc2b7efbdeec40439bb715aab8b5c7121996a918f1";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "36ba9a0f5e3bbf947a6b534adb91d42b992f7ac6352f12918e64ebf73be00a72";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "346ea97db0540ccb07fb9f4fec8f1d15f3263fc4c3102e631ea282cdfb08ecaa";
    });

    libllvm16_0_50701-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50701-amdgpu_16.0.50701-1664922.22.04_amd64.deb";
      name = "libllvm16_0_50701-amdgpu";
      sha256 =
        "e5d8c0ff759c2eaa0ab95c6b8b1e72807aaa18958442a8e9c084fb0008747ddd";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "0f45eb2e3433c706e522667ca0ec33bb88e4105d6cf7c7f9fa7d53c48279bfe9";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "1d4aaabd9a051921809c22982f8042a9312e672cd1b770a938ecea6525bd9a34";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "00321f5c996c9c40ba1dd189d498195e6f0c7f125d3931092d60adb93284c1a0";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "83c1b0e82c7c8013c16a42c4771333976570dd2dd3b7223ff65aa73b70970488";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "a71e0725f961b20412f2585523c4765a99aea857326f6fcd934fc1f54ab6ded3";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "1cf1be8407d934c19d0e935c3aaa8e6c9eb0983aa8127af960356cd1e1518c9d";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "92d339a411785d8e6f7ff5689edbd1ebaf0d220cbe1752d36637f204bac92cd3";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "32fd83002f4006949509f55f73236a83fe96e4cfbc050825f61ec6e3e3aca17f";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "bcc53938302e0a306fcaa7bdbd2304d4af7ade1325f13e0e2c6afc56f6e9590a";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "8ffc01cf19472c5afda1dcda5e963d13fbd93f75b3132363199021c15be11b07";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50701-1664922.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "bdc396d460b69061657b14c95b97a5ec249745e5615e6e25c344b5d144803196";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "d197189245ff8b5f3738e7a1a64e28496fe9d78c9f8c57439c1e5136dfd91f80";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "85c07c823a6ce9ac6ce3cba3e6c8673ff33dad6504a91f88ae8433f8711953b8";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50701-1664922.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "b563747c4167f87becfe973b2d86e7b57bc04a1a4d57047a8533b04a7cfa6cc5";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "d54044ba7dded7095ac8c4ea7dcec3ac138ef0bd28bd2b529496179f434bba22";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "8ac17d8f39b729eb62307ba1f1bc7ffdef81c6eade187ceab9fcc51cca5b04b3";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "2fdfdec036e904faf3c41238d47b3bce264f9a3f9fa72303f17bb78e9018e61c";
    });

    llvm-amdgpu-16_0_50701 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50701";
      sha256 =
        "985c61ef62c0d136b3e41e7e666ed29b027ac228c9cc13f565cd0a09fc1f429d";
    });

    llvm-amdgpu-16_0_50701-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701-dev_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50701-dev";
      sha256 =
        "32c32d2568ecb501ef7cfc19bb4d7e181a1a6752e7c794519561ec90fba0dd52";
    });

    llvm-amdgpu-16_0_50701-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701-runtime_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50701-runtime";
      sha256 =
        "04509e16c08e65608a8a299c06f58dfdcff688d8f66d2f00c5e1abd4376f6446";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "c929650e600279230a24e4e0af4d1f0b78c27ce514ff4d8eb9b3df09743561f1";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50701-1664922.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "67acfed2bfff37b4ece95ada1825724e441a52088a8cb289892dc486b5c23e8c";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "2d9101f77c449adeae8a413953356b1d460dda2115d4e1aec5818312b5810e81";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "c832007419dc53156ce67f34ecc8d9362a64f0c7affa34c1275fc87c440c516a";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "a9917f07ffc2d5a5397ef8fe44d069b8550b765d208db29395703e648b510124";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50701-1664922.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "3054af5ce56eb11a20d30ed767b83e9888d0efee4d7cec5796450feaa23c6525";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.20-1664987.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "a30d22de4d9f3ed994396a9d79c4caded0b6fd50ea3ce770512dbaf2be9a8db3";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.20-1664987.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "0cf029d44ceaac050f8083bc00c690ba9ddf7c21546c963f758750f9e7710f60";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.10.0.50701-1664922.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "0047a414adc89732771a52fb2f1b970e6866641e6305a6a736a25cf70c6739fa";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.20-1664987.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "62e936addb664916ff5362ce559d39504d2429828575c10ba0705a458b426665";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50701-1664922.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "a1fb4adbe90e1f5fa07e34ae76e42a1b8edf55971ab7f7ba97b2f92afe146e26";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50701-1664922.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "1e6a4399193c3b3f2daa74f7949becd7211d02273b98a87c721fa82e7dbeca5c";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.20-1664987.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "76a665fffa3d80e643bf3c58e95215b3e61d2c8b151ed96b9d5412328d262da4";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.20-1664987.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "b5e09509b7d7bddf3335d81ba7338cf2d86c1b76ae918e8ae7331fd407867fad";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.20-1664987.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "3e626175ee74b160b82bdb07867041b563773eac93d617f9920044193d63cdc8";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.20-1664987.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "5f22df02b3d71aaefcfd436c88b62728fe4702ecfa904793e6321c43be56fd52";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.31-1664987.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "bf74e996e88db6751cb43931446a7667474e82d6e5d015db62b8f42de6b8cd57";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.20-1664987.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "e82bd9619a69fbef94cfe36626132a381608586a75dd330c9bc6f4c61f82d583";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1664987.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "ffd3d3f1a2797598bbb9f529c4dae9da01ed49e2de4bb6bdf862960caa6e2f1d";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.20-1664987.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "d50946385fc0b2c87a3eb20c9b26543de56cae7bf244c74e178d3e206178c1bf";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.20-1664987.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "642bcfad5c771db94e255590b10d9125a52d2a8f0f5aa73b9384dc219ec59dff";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.20-1664987.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "497dd239105d0daa6729cb1838db8293924e115f33144cace472ab7d5905afb2";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.20-1664987.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "fcbf5109782048fe0a1a7009d6cb9608bda4e93760f7c1e4c7314f85d456067f";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.20-1664987.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "99011e93b8c81de88fab31f58f48d91bc954db6177bf68226b4d06678484e847";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.20-1664987.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "ee59e2548e19f0d13320978a5238eca4b68195c3fe5a855917d64d14eca4be7a";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.20-1664987.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "ec874821372d64d1050264b280a87353354734eebb7bbaa14b291d2e520aad0d";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.20-1664987.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "01200b2f3344db9a5355db1ea4906b0cc222a27c4f4f78224602daf91cd10992";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.20-1664987.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "334673cd161f3881e6bf45b994f71d781027499e2a6d6e50c57a16c96cb7942e";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.20-1664987.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "194bf41a21b40f8305f532818a5d2491dca0f6f0750b3d2b538c54f57dbb2dfd";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.20-1664987.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "76eb0c047d2a8fec263765a41af82642c9672f3f3c4849c660b985f9c9a7ef98";
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
      libllvm16_0_50701-amdgpu
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
      llvm-amdgpu-16_0_50701
      llvm-amdgpu-16_0_50701-dev
      llvm-amdgpu-16_0_50701-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
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
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50701-1664922.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "959d31d673c6c632e8816fecf5a0bc6bc342cfefdbb9655cb1727cb4d6356e0c";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "b06d61c2a83e9bfab552c170258c23b96a1453d2dc5d76d0462f9a2221b0e050";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "b8360086fa9670d992c14a0746aa6152bfe4ec828b09f77afb2b66f9a55f2d2c";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50701-1664922.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "139f22b2a0cdf83b0307245bdf400723e97b1426cf880feef04a950fb18873bf";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1664922.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "2560b85b3cedb8a9cdd4b230c724dd82957f0e4042985ea0fb5ffbe09882f361";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50701-1664922.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "f9dfd52ab86178168f0d934ced4d7cb220d5cecf0f416eba166c3cb26c8ed0c2";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50701-1664922.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "78748f097f706687e1dd5d247fd62edeb037cbb3230ec1b789595683dc4df71d";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50701-1664922.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "d8430ddfa127d3137cb7e13b011589d3540bdc9ff9fe6292398ccbda17a8182c";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50701-1664922.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "ada6502a34f7f684298a5ea8f0fe39a46b6f7a9ba1b0a6f8e845c05be3a6eae1";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50701-1664922.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "dd51ce58aa9229e09753daa806c25784309a989d6dec97ae3bb6b5f8488b37c4";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50701-1664922.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "179fde693584baa73e67cb0b8f549d62a5202cceecb9c5c3b8ff79d0144987ea";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50701-1664922.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "8476015996b1fa5f0f9593a6fadaed305f832544baa1132a70dd01f7f312c901";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "d90a3621e800018382fb0357ebbe711425039beefce222d71d208cd7d54cfd10";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "b85da68dd2d924c0526c52d14c76f78689f05b82d3b9b838807e4e5814e55d14";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "cd873ebe8fdb9f6a7e8b82d8a2b0ff4ed6af3f4d0eab9e0cd5982e83ef63ac8f";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "cb5df1f88fe72156fc50700f767894987462b953f08a6602d9e411847de0c8fe";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "f5d38a3531e628f08c0fb2e225d00646c4017af2f50cd53325a5c5c974b685cf";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "5a3baf687ae85998241f183d82a4bd21779d268a018a7e7d8ae2225bda967594";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "d2d8f733a9de541a22a81f24cd9f6813418aeeff2f9b7cce3bab7cc5b8fbb2af";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "fed5619b0d0050d8586040f9a20fb88e61165929bdfb1eea3a08e9be95a7e6d6";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "4a8d131047a5783467174bae23b77c90b20c4f831e51ad5c2dd3ce9a5b8084b9";
    });

    libllvm16_0_50701-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50701-amdgpu_16.0.50701-1664922.22.04_i386.deb";
      name = "libllvm16_0_50701-amdgpu";
      sha256 =
        "4572ff8c5a71b3425a320187980dd6b6bf1b58aa421cd716d07055ecd9844be6";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "ac73299017c54a1d3e64d486128ecdf4b3d7af55540916fd1f235d20fcfa7ac0";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "0b690b4ba70d86bce76d813661b818d6a01d499c3a480d4d670e8fc78f8115c4";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "7d056187e5d3d181db6760f799bf56cfa6cffc7463c0cb3c7622732f4186e4b3";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "e050181a0bdcc16d4925a22868935ed532a758cdbd4a1fba85ac4d0c880aad04";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "19cd247023f457c0959e164897846195619561df3979b8a5089ede17917d3271";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.10.0.50701-1664922.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "d94a44e46b9467bc13bf5815a05ded8d87912cc1ce9afede107153173e2eb0f4";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "7bad45a423b46239f30a476fb05912b21738c74b66724c6e233ef51568b4b3fa";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "9459bf04b9fdf9b7cfeb1574f37d514aafd20cfc1ab466bde1da9ed93b710b83";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "892b962e7df402547366631c03173e5695a5abb9a2dbf42337fbc03064828526";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "89ccdc67b28af17367aa9a9ea41ab955267a657a3346b096478fed719d680bb3";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50701-1664922.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "bdc396d460b69061657b14c95b97a5ec249745e5615e6e25c344b5d144803196";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "10e8823f75d6b7d800ccfef27ac11909e5aba84d3cef9deba217f39d5e03ca71";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "8a4b874dd34334806d9d7ca686c8b59de9f39a01af4ae291526fe4b290dfd551";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50701-1664922.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "8f1bbf8f2ce6334442c1a789703e56e8a88e04d22e640a726a5aa2c643138f63";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "5243451aa7b79db2ed559dddbc26592aa3984fc5a80bb1a9d6da08d8ce33439f";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50701-1664922.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "175c761b63f08b245ee960bfeaec4aa0fc6522968408f56ce967c03fdbb4ec39";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "fe13a361483572f10f41038fcd6925279dd71336112ff819bb789b6ff8d7d90a";
    });

    llvm-amdgpu-16_0_50701 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50701";
      sha256 =
        "1546f4b484bd2001aef73a8e2a9a0719335f97ff27d730b87cbdaa7934e36ef0";
    });

    llvm-amdgpu-16_0_50701-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701-dev_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50701-dev";
      sha256 =
        "0eaf0bdb75463e4dbe2762083647ca34d98340e4f5b81c88fead7b9314cc4b6e";
    });

    llvm-amdgpu-16_0_50701-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50701-runtime_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50701-runtime";
      sha256 =
        "fdce0feb6f5c4cba2e3bdf2ceeb6981bb4bd64447dc637fca9615dab12b41e5e";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "f3ffada8509a49fab67cf890c638f38a8f17f71b95b99528161a97e45b89098d";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50701-1664922.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "9f0b0e4238d78658da9ea1ed28c38022926756afdf759eb01148ee713d0f2192";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50701-1664922.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "09c47d900a672e7e8185eb348344562a2d2c9908a2979f4db131c0cb7643cf49";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50701-1664922.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "1e2d8d2cf98292c5d399e78fbe250955292fcf85743efe60fb0321388976c0b3";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50701-1664922.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "55056981f21daf50c68b8158d446add32d8d61cb4ec0242b56da90e3d9337997";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50701-1664922.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "f7d9616fc6e8f1175eb407633d5927b8d3d1592e9f56377ace0cf11a41400b94";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.10.0.50701-1664922.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "e5d627e66b579637e710a0febc78cf26770cc6bf6240a06f01d10a18576006e6";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50701-1664922.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "a1fb4adbe90e1f5fa07e34ae76e42a1b8edf55971ab7f7ba97b2f92afe146e26";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.20-1664987.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "b5e09509b7d7bddf3335d81ba7338cf2d86c1b76ae918e8ae7331fd407867fad";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.20-1664987.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "b706868c426c107646b759099dab10ce9605e90667203e0be726ce9f80c7fec1";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.20-1664987.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "6ebb2e96076cd89a59badc305fc1a2694359f3b69864f161c77ab2b5a18a5b9c";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.20-1664987.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "312905d0af861c066af925725942906b43fc8ebf8dec585062ed899c57a544e7";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.20-1664987.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "3b270681ecfd168994ee012000bdeab3f815542aa90a28f98a7b6e50caf59fb7";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.20-1664987.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "b4364922fddd0877ad9ed4c3c764bd2881b6c8e8f33e0923529b30200be934f0";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.20-1664987.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "3bcfb6d5ee07d4482c3ab6cf5b41b2d23c9f8d75692e2331ebd1a70ea4e38f7c";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.20-1664987.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "89e95c2a6fef050a967ffe93654db89a8b20128219954c30f5d5fabdfd96369a";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.20-1664987.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "99436d2c56ce105330befc5c9376f9bc721dbd69f844aa5d5efc11b93f81006a";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.20-1664987.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "fb416e117ebf9e2233e820601ada76750e997a8cba2bf91848a3209e3dd4cf8e";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.20-1664987.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "099792445c65210d3d2bd771e3046740776f0405f215f0f9ead5de229ec54700";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.20-1664987.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "1405b1ce1a13fc315675d1e11fb80938c53c9052b9db3f6bae573f6de7313af2";
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
      libllvm16_0_50701-amdgpu
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
      llvm-amdgpu-16_0_50701
      llvm-amdgpu-16_0_50701-dev
      llvm-amdgpu-16_0_50701-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      va-amdgpu-driver-all
      wayland-protocols-amdgpu
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
