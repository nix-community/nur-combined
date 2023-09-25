{ fetchurl }: {
  version = "5.7";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu/amdgpu_5.7.50700-1652687.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "3044efecf0a9f3d78b0d9cfbf18e5a5bf8bd921627765b6e8dbb9cec1afbb8e2";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50700-1652687.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "79c4c5f02f1f2a8799b7aa30c4af91c9a1f254b17d4e6e6bc570d6124dda1de7";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "f3ef19b1c8e6aa42339563676712282f6f821b0dede22d8c997625c661b3df6e";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "389a8f4db2507831422c8d159f99d37bb41ed16f12aa270fa49dc3000de0c5c8";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "5d73398a1892f9d9b9d143f2d1780cf80c609a19f3319723386bd617963ad8d7";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1652687.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "2b9782590fe20b1ed6e5401e36825f3c7f23aa2e06571d3061de69d42f5517f1";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50700-1652687.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "dbccfdd718655939e14400063a919a1f22bfa5babe5ac8f53ddb83c61bce384b";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.7.50700-1652687.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "67d4e52aa2f4c63135a2c8ecf5bd54fa3652387d1b8f6f48bbcc35d15864dc40";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.7.50700-1652687.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "b1b4eca2f4d522a1f32369d89cb68379b8acb81857f1791d48b93ea444cd878d";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50700-1652687.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "0327c771debf01a0715246141a99d8100adb35e519b35535a3a2cc06e29ec434";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50700-1652687.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "a4883f1d8af696f749ab4eb903667dfdf6c75b2712cd8b37c717cc969ad6987e";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50700-1652687.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "d39a5cd9f868d667f123671d6d19952d4e00fdf0fdbb3c9c54192c7181cfe029";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50700-1652687.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "c6f2c2cbe3a1ee0dfb3a1105ff3e1509cb751d1dc9bad709fbc6843259a1fa8c";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50700-1652687.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "f2c6399688411c5cadbca63bb8f1401165d94a92296de76f67cd0e2f68ec969a";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50700-1652687.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "f8aca409288dd204a7cdf8948fe998edf69559261881113f3e45426521b46be8";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50700-1652687.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "f9bd94b4c11fdbaccb9dc4867045ef5196acd76199d83bc835b8844e5b33778c";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "e1e807bc3c06af5d894bc244b4858f26157e5b40af3197676a6b4ff0c3f96d2a";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "7fa64382571d48b39d403c7ebab8779bd5f6f2730824f97b99db992f6f5d0ef9";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "cc115d1dff61e99b718fe0f48e6c58e1410a246d06a73bfa10871d35571b56c4";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "edd358adcc59a3b9931488e56430d02d8234b5a3660e8f86c1f272bccd766864";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "d5b6c5bcf8b749b7fab352c95b364646c24ca060e8bd7a9258dd24679167a891";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "92247cecdf032c14f6a522f519319a47a417ec2d27f046b1f4746a7498bff86a";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "3609b5a77dd9682ca451710415814fab379c70bca86a4e1dceb0c45ddf523503";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "304a078aa21f065503d1507939d1aef66d07ee9842aaccf8e340beec0c7d54df";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "0f9f63aae1a33dcecf219f926e42006a40beff55189ed47d2cb2867446ed04cc";
    });

    libllvm16_0_50700-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50700-amdgpu_16.0.50700-1652687.22.04_amd64.deb";
      name = "libllvm16_0_50700-amdgpu";
      sha256 =
        "6b8eb292e116dc2d9577fd944f6b829fb33bc1a52d0ee993312c292e070992e1";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "80d2dd6024f5901757801295a66f3a93ae3a336ccacde06a2a85a357283718ef";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "524b08ff3dcc4888f19e9174dc71f7013eb25f594a32f965d7ea25ed7291a531";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "398ff162b64267462b293a8d8d0310e61ab81273f7a5403702da78868a751dfc";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "559384cbc0768d0836343817ac10e79ea506b4fa87ba93255eb173371a28c051";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "0c9f9e2ee409163ec0f81db4435f7ab33adb8023dbc39ffced92be33d6d4a62f";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "c6d23628f255ecb48e9efc54aa486a3b74ccd9ff1ae6b990312a870f3c66bbd5";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "758a8876b0164e088a88c138e3438509a5d71e194e2722c1dcfa73a79893adf6";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "155a3dc5918e4b99ea6bbe38a8b365d287a2d355ac543c92a929d7d73de6f68a";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "d6dc4a9efe87788646d1806ec61bbce2a182f2f3e3b297d6882cad9a02ff193d";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "06540306015b80859c4d2ebba91079e81a3bc77d7b0b5af441aae02de47c054f";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50700-1652687.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "d9b2eb2b998cc3df4c471cb16f3a8c79476a6bdb225b702cea1c4681984819a9";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "429f12125e2d536e22e99ff49d5f2ba121f08a0506834481a7d76d74dd84f06a";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "2f973509e146792b7c4999336dec445404cdc3dccc218ddec7007ac4ac743d03";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50700-1652687.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "48c3f02c19e2bf0b6b368d7c2c4d64656113cad747af8f62812fe34b886b1eb9";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "ede42790296a655a50fa076296ae0c04f00b24e5970b4b8237f2d5dc1b1a1d5b";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "862f2f54cb74e82c28608b7a0ccacdfe99e180ced8871909e0c732cf8f69e99e";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "18fb624fda8756edadc7414f8e7386eb6f695fe5e74342b4044a91df71d1ab98";
    });

    llvm-amdgpu-16_0_50700 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50700";
      sha256 =
        "67671ab80aaf49e5d8e5aaec4cb1cdd0c59d2ac7394bda10f5d17388d1efdd73";
    });

    llvm-amdgpu-16_0_50700-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700-dev_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50700-dev";
      sha256 =
        "f2cafe04ea4d515e0f68834e98c0161647495cf45ec070f5d5a6b3bc500bbc66";
    });

    llvm-amdgpu-16_0_50700-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700-runtime_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50700-runtime";
      sha256 =
        "660a200461725a9af3c57fe978dded3a28f9efb4044e105b59a2e488045836e6";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "33a5ef45164e8f7de48b39e341ea23bd6ee83c37503340f6906c8862fd7794c6";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50700-1652687.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "d495206510b525f7c048214fe014e10d5189fe2b456712b551524463639b33a1";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "cb9f27b69d7092eb62088790f2ebe117aa2ee067f79a1f1b2c2378f3f52d4783";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "ce679d8fb24c6daffd92ad5f74b947bb5ce067f29ac386ef13bd614bac87181c";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "2b8d11e3b1e0a03c00e07da485fee4756578a7ae26062299eebe87f80b792357";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50700-1652687.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "729a0f81a453cafb9628b2d7cd808e8129f5616daf7a9be4fca2161fa9a87b0e";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.20-1654522.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "a2a14b467e369ca96e6ab580f3d9245562c36e64ae60d5d4d359e9f0dec76e7e";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.20-1654522.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "0e53ded772e892044bf4424eaf7aaceb9cf7ab952f2e10d1a4832aa02efdd651";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.10.0.50700-1652687.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "1970b59f5a56a2fccf72d64ddcb6b914d07937628d7103502982b9eb9c94cfe9";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.20-1654522.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "0b1318f3125edf3f8e7fb2af87329ffce308f2a21763473e320665e6f8ebe9f7";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50700-1652687.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "ebb0f36b5134391cf4c83b9819ed1a521dc0c91ef275d07313b10e3bc616e0f0";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50700-1652687.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "146fa432000790bed0df93b2b7f2177875331c3fdbb4c17783cb0298c875548f";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.20-1654522.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "d7f1e411ee15e0a792e105005db745722442f491636528eac1680230ada5f21b";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.20-1654522.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "7f9dc0a12c409840a5160f6f53e1f29cc50c9921e5bbb12ffa02cf6096773e08";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.20-1654522.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "45a336ff36145b9b5809e1459d7691a3763398524c41aa585479cbbb6ac39445";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.20-1654522.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "dcf2fd441b0b266c0902a308a61d5f3647d9270c9b95a5a0a82cfb959a56304d";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.31-1654522.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "6486b32a80f9243996b24917ac7cb8a6cea78f280ca94604d96b28c530e82aa2";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.20-1654522.22.04_amd64.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "2d92349074525b3ce3bf74c02211e501d1dd955c09944953ff935320b1047cee";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1654522.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "6c1a74a635b2de70850cc831638cc63176a8abb5d6811d23888a367432fa2b63";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.20-1654522.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "49794cfd3d2b1226365b19882da4237626da7fe7157b51b560f83b5eb75b2a52";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.20-1654522.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "54754f38b1f6306d4863439263c1b09ca183c948ddce63230d0b83636ec45d05";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.20-1654522.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "57244d45f35d89823b2fe3c55386d8dd3233478802f9e6359be460cb5d6a8239";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.20-1654522.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "d659cedd625b6c16ee3d26c7f825aa1769243e43b666afd73214bbcb3429a485";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.20-1654522.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "010bb70ef8353fbb12a614857e8b4778de3150b6c18ddff5e270d03029eb47e6";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.20-1654522.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "b96b60631c11aea3a0b599fdbedcc9ad77db3161cf071daeccb763db2807a0e7";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.20-1654522.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "282117b91ff682b4a0a04e448aaa6d371f6c0f9f15efa0d1378c6af007df55c9";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.20-1654522.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "8377548e754548d859163824a10257a101612bb744ddb551f5241486145aa298";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.20-1654522.22.04_amd64.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "7c9186d7ef0526684104c1df07f143bb797b7c0c1a6ab7f49b07c63746fe0bdc";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.20-1654522.22.04_amd64.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "bace2ef86be1dc823894e242e5077a70898062cc5b4db40962c19ca5bb6cf234";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.20-1654522.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "6b2ae59acc61319ae6ec5fc68534324dc9ed8bfe6a70812bd2945a37f3e0d905";
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
      libllvm16_0_50700-amdgpu
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
      llvm-amdgpu-16_0_50700
      llvm-amdgpu-16_0_50700-dev
      llvm-amdgpu-16_0_50700-runtime
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
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50700-1652687.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "79c4c5f02f1f2a8799b7aa30c4af91c9a1f254b17d4e6e6bc570d6124dda1de7";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "f3ef19b1c8e6aa42339563676712282f6f821b0dede22d8c997625c661b3df6e";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "389a8f4db2507831422c8d159f99d37bb41ed16f12aa270fa49dc3000de0c5c8";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50700-1652687.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "5d73398a1892f9d9b9d143f2d1780cf80c609a19f3319723386bd617963ad8d7";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1652687.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "2b9782590fe20b1ed6e5401e36825f3c7f23aa2e06571d3061de69d42f5517f1";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50700-1652687.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "dbccfdd718655939e14400063a919a1f22bfa5babe5ac8f53ddb83c61bce384b";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50700-1652687.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "1f907d36683d9008f2be09d8f1cfec06e162330261f6c3451e1b9b5358ce2cfb";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50700-1652687.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "d39a5cd9f868d667f123671d6d19952d4e00fdf0fdbb3c9c54192c7181cfe029";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50700-1652687.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "977461c6c5405c6bdd70a0abaa0f626986d3e5845519f3635328542625a181ba";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50700-1652687.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "7f56142104823a9b213f13b4cd791c47e18aa44735ef212ed8073e2f596d31e1";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50700-1652687.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "32531d63596a8d5144fd778823ae6442bf3723cbc29dcbfaf71949ce70282f1e";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50700-1652687.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "4562966bdb34a2c02c47d2cd2361243b6158efb80706ace8b56ade7739aeee18";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "da6393423cf473a40a46f119e97ffc011c2ed653c1e8c178a75e35d307522f35";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "10c48aba1c9763b7caf1accdec5203bcf721b075728adbbc15955847ee8a8bf9";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "73288e261e203e084e211789ec71f7c186af3ff00b1bcbcb0d8f97cb79d8dbba";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "a06ce05c0044b061ed84e3a89598afdd3c5b2bda4673449f1414c2cb5f8bd7c8";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "3905df640eb68f74f88d43afbce97de7ceb7ba8d94f89f9bd50e48e6ed7ac27f";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "cfe61df80ba5a8ab95ccc4e4ca4c9417bd74ec3a3570b927be61b413e0712996";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "6fdfdf61f9d94c52b811cd8c1b821f14c2d55ce46ba3f61f53ef513de0832033";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "a35470d4a09edc53c0ea9b5f0f31075ed15330bd96da78d8a1f7c31c0acadf90";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "dd5469033345ed54d7e1d239c17b6e6be16703af16980c0318a6b66e44f0ce51";
    });

    libllvm16_0_50700-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50700-amdgpu_16.0.50700-1652687.22.04_i386.deb";
      name = "libllvm16_0_50700-amdgpu";
      sha256 =
        "0a2d9febe001ea6347d99f98889c88baa0a87b27aa399faf6d9a05e71ab4fdbc";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "f4db2584ab86e54809522e257341e38c6ea860c33b6f83a4b08d2ae4f2414e48";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "66896623b91f3f7828386d3b0aaf5aa7ed4fa98ca96ad2b6864fc491b1b50b2d";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "7fe72b7b253293361455727d3662b2aacaf42c6e49c554bd4654688ce9a19b91";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "3c0d1a52988945864070665b55591e2bf1fcfc8319354e0a4a59b80260a876ea";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "56f269b3005b3c0c8e5664ea18bb0a509e0b7c9f0eddbf2b7727dee2366cb3b5";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.10.0.50700-1652687.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "208745783b8cb088cd3993535a6a8a4a45b41622f94b2a6135d27f51af8be480";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "ff6ca7f56ef670d72b75b369d56e11762d9931f8ff1ef458febce2ee7d3e2a97";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "22868e54bfd25e2273d89c723027a9b9d6327c4cd37c55d311ae4f117f781df9";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "063fae03ceb3e44065a4f2dfe2ff9a4e3c2604b5d95988d60f71fcdc1124663a";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "cb64fc4c7b45612d411f6d2528c0dc47fb04eca8bce3d5bdbc86ea3ea4b97aeb";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50700-1652687.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "d9b2eb2b998cc3df4c471cb16f3a8c79476a6bdb225b702cea1c4681984819a9";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "bdc3a3bfa801a12983acd1ba0748223663295168f989a224725f6b4cc8db3ff5";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "6934d8c4453ed945d8d892cdc125a279c586b2caee544681275a18d42d512d58";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50700-1652687.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "d11650c7c9e5295d81558e6d6c54a45cbaabcf95a873b38064cc32953f5b0a21";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "8f664122b3042716677a06d6e22aff09f5c66f00c58870382054eb61b69760d3";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50700-1652687.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "73ea7dd88bfe4c416739e71bbe19970f8d0ff5033e735e342ef72b5a1aa654a0";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "c51ae82b63dd7c3bbc5692596d090a54edc33609279b230005a18ca2a27f0589";
    });

    llvm-amdgpu-16_0_50700 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50700";
      sha256 =
        "acb53bc230357d1682812c73de61ad682b1cd88cc8dac4bece5331dcdc0391f3";
    });

    llvm-amdgpu-16_0_50700-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700-dev_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50700-dev";
      sha256 =
        "3dc5b337a0ae7b7cae0e416cfefef2262c5b6a98e8befac60802bc4b5c6154c8";
    });

    llvm-amdgpu-16_0_50700-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50700-runtime_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50700-runtime";
      sha256 =
        "d84137fa874732cbb1657c19fa61195cbf8c93f4bb05531c0a20945f3edca0fb";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "6b5f72ac0f1826f1b7d762f8510f99d8b980fbef7643191f1522567a085cfb9c";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50700-1652687.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "831eed8474f98f0770ca4eb7f240b6b0a53bb901ba4bacdfe7b0129fc3019f31";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50700-1652687.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "2816e6dacae9fa28b9edc5b76e74ee16258ca30b94b5c9851b08c867cd2850ae";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50700-1652687.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "6493fefc6d671a5fdd828859c500555c9ebee01653eebe2ab69b9350040107e3";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50700-1652687.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "d90c63a734f0b2871e7a15e037d411211eabc15635187b18c04aadfd742e13f9";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50700-1652687.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "1fecb3050c75fb767e02443544acf3f15fa72995a5e9bab9947694d84c830449";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.10.0.50700-1652687.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "a6df1a327cb1bea26c2d1b455cc88586219741b0237868f73a5c9ce0f6433b70";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50700-1652687.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "ebb0f36b5134391cf4c83b9819ed1a521dc0c91ef275d07313b10e3bc616e0f0";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.20-1654522.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "7f9dc0a12c409840a5160f6f53e1f29cc50c9921e5bbb12ffa02cf6096773e08";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.20-1654522.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "733fa49ba6f5f07666be9d1e0f46a22f86688000c91c365d611743ca0c4e0715";
    });

    clinfo-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/c/clinfo-amdgpu-pro/clinfo-amdgpu-pro_23.20-1654522.22.04_i386.deb";
      name = "clinfo-amdgpu-pro";
      sha256 =
        "bbd013627c1afe63184956bcc341ba6a2f37ef193585e70e80a4ad0dd8a57785";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.20-1654522.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "6b142ad1319141660e73305a13c866a7924064681263dcc8424fd402f3b8f830";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.20-1654522.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "be25a5fe4efeb91066ec345613e373193b7cd3db22201045f34cbd1d7f47b2ba";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.20-1654522.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "f774d763a53fcfec605214c4058a653d26c6fb479457260a0781aee8af9b8708";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.20-1654522.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "8b1a6066d8a8d0a08ff5abf1998be223caa24cb5f1203185d85a93ba8e727fef";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.20-1654522.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "c5e6aec8fd970dbc2bdcd5504abc3db3ef8bdaa9666b66542151e30d83cccd3a";
    });

    ocl-icd-libopencl1-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro_23.20-1654522.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro";
      sha256 =
        "c5da97d5a3b50fc32745cb880f5244c54fd69f9572b7d43f6ede1178224a4d5f";
    });

    ocl-icd-libopencl1-amdgpu-pro-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/ocl-icd-amdgpu-pro/ocl-icd-libopencl1-amdgpu-pro-dev_23.20-1654522.22.04_i386.deb";
      name = "ocl-icd-libopencl1-amdgpu-pro-dev";
      sha256 =
        "859c827b5b684407e7d234cef18e5c7ab8bad3068c7a29e8a0f88c8ae312f679";
    });

    opencl-legacy-amdgpu-pro-icd = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/o/opencl-legacy-amdgpu-pro/opencl-legacy-amdgpu-pro-icd_23.20-1654522.22.04_i386.deb";
      name = "opencl-legacy-amdgpu-pro-icd";
      sha256 =
        "b643a9ecbb8bea839fbcf4c02bf77e1250a878968ea0c9a47a045e46ea26a222";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.20-1654522.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "66cdd60fe04da5b6efcdd628b6c8c63584963f053c22aa1df8959a2ff5d77c3f";
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
      libllvm16_0_50700-amdgpu
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
      llvm-amdgpu-16_0_50700
      llvm-amdgpu-16_0_50700-dev
      llvm-amdgpu-16_0_50700-runtime
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
