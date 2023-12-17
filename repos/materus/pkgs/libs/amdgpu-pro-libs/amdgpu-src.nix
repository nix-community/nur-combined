{ fetchurl }: {
  version = "5.7.3";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu/amdgpu_5.7.50703-1697730.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "7c5b7400ee3a95efaa87a962bcfdfc2a57b03d018f8bdead155d34a8f7468dcc";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50703-1697730.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "673122a73f82ae4f7b2e8573401c038eb3c216b0f63207e717d4038a7bcfdec5";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "0a788d501167cdf05356d1e7c89cb9904e020eb3f6c791db8e81b4067a4aee0b";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "45ad99ee6f8c2e989487ae6c870a7bd5555202e397c026ddbf3fb54b558da480";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "5dd3762e8603999620d93ca6cc2ab2bf667c1aba7633ff90469b15fe64ffd993";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1697730.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "6a5601f0a03d52feb2f99defdca1d53d6266e86d6172a63bb48f61fc9fd1f05a";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50703-1697730.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "ab0f5d80f6727511612b2992204cb65e33e5b3917dca68ebc6829e4e2d66b43a";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.7.50703-1697730.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "05b48799a46b63eb019c5f42521894a58e5a9243103eb6ee8b4dcd04a77eb158";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.7.50703-1697730.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "9d541b05868b9c61c6454a2b577d38b8787f81d4bedc3932b83ff9db6d9acc3a";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50703-1697730.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "4d3bbc481d1b52b5da55d948424a68940583c2c98c1059b60d8d8296a3ffbdf1";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50703-1697730.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "9b036703a627332fd46037cb72c87ea0fba06a40ccc5ee6889678ad3566d7f0b";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50703-1697730.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "ed808cd1c7cbd5d9c2f4899d5e67d3a5364e8911be50c462bceb81c23f4c9791";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50703-1697730.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "43e161aa062e60983f579d1d51f8cd484ebf6460dcc520fb2d2c8a39995df1a0";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50703-1697730.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "c0918ee5efd546313ce0a2340aee4b84ffde0656abe51d00d2e071a370d484f8";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50703-1697730.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "635b92b326f17d46db48a914fcec19dba74c901094dd6d9dc8023256348f9630";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50703-1697730.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "0b853eacc3d6e33248a90f97e5d1db9ab3c7a56d7414c9ceb30df0069c581da2";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "24eba315ffb16036e90ad5a83d9e1bee38e7ac364553f62341cbd9780ba6271e";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "b8d816e958c4ab20c3a607de2a4a50f4bbf6dfc8d309494bb6862a5197147951";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "c60a4888b06e06316fd12638dee9428770b23d913d309d5223811ebbabf1c5e7";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "a553e74f56baf041f24ec465adab9d93edd47a1fa94beabfd1bd8bdf26d8c135";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "f94bcd4d8f5066f8cc15155120603b54a0fc425685674b31cbd15aeafe91b8c2";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "68772079dab9b3328efe3a12e108139c1886e48e784b3bdedf04f0d04b2d2549";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "0b334fe5202404c7d896136e17e2ddac8057cf2f7a531dff45bd68353b8a9ee6";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "f7588789f29ac9be3269fbacfc390a80f1eecd73698645490154c59483934e6f";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "72640bd8533faccadb5d0239f179a74f21d677ca159d8de4ec0ecf5e22fb0976";
    });

    libllvm16_0_50703-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50703-amdgpu_16.0.50703-1697730.22.04_amd64.deb";
      name = "libllvm16_0_50703-amdgpu";
      sha256 =
        "b669d7442857504e783e52a2623a9b256f0a99396f22ae0201f250c8d98719e1";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "542e75c77c591f3c3810e33796994c501070f4f2d84582aa8b3c20f05232afc9";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "027a0c24e8c083bbb2cfa109edfa99de161eabdcedecd3ed51b2c5fc7d335933";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "84ec51fc88b209a86cfc7230fb7bb21d56f1dbcd7de7f7a66adb4c82c6b5203e";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "c2dd01599a7cea3e256fb1da348e8b0a68d7f442015b170ad5d62cd6171c9bb5";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "d6c8d47a5268347ca33530e035d3e01538e82277819456a82be88db6a6c9af27";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "c9d820688b81a6034292a146740b8acec42ae07606555d74e721a06863edfb55";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "5cac4c04d9d8c8a92449fb12aef38dfd6ef8a359dd5236499b04cb9b0956fb85";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "d5bf9c6b6a8c77016d1f4d6524d54a5256c729873be536bafca931567005d651";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "1ec1bb9fb049311dff2401661c5ffbdf898a1188e2d266b9255fc412ae8b2974";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "c714e3ec3cb62abde72c25eae478fdb9c811b637d6ef77596dca78ee5b230cbe";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50703-1697730.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "455d1ee4e79c11545888dabeb39429e4bf6774f52e2d9b5b58bcb4e0d0fff897";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "96f364c837ade8cd5e7880243ecc8d937ef028c8804673aec4efe6263c3dbe58";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "6e9bc05620a2b31e594241edbb4cfd47b478186aeb86d84f6d12ab97e30267eb";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50703-1697730.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "3bf867074eea991062a50ebcc2ccbe7fd0969f814e983f43d8f187aaa0d6adf1";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "985c1a90795819cbb4b7b06ec7da1308e0cd1d1cab8845af0002be46a0a2c3a0";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "84935f62b2f684972a0fdfe4d219d27bc9fe72f3f676429aa7c77f48f4ec4aa5";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "ad6f49ca84ff5280452e0cbae2a49669a8616b2afaa149ecf5345a1c815d5442";
    });

    llvm-amdgpu-16_0_50703 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50703";
      sha256 =
        "2e5d4b18c1ea29478ac9b04cfcc4ad610d31cccac2b8e0226a57c16a87a048ce";
    });

    llvm-amdgpu-16_0_50703-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703-dev_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50703-dev";
      sha256 =
        "81d2523dbb98b41d0b892e20c7bed0c264444265d1c66cfaa7e11a25209b3605";
    });

    llvm-amdgpu-16_0_50703-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703-runtime_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50703-runtime";
      sha256 =
        "665438d503dd47bc0431cd1f989fbcd6dd58da5350c93463cdd8f5dc0cbba338";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "8e09acee2bd11c16c2231a6d65b57b71abc62ac8a56d426c929d076ee1be4ec6";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50703-1697730.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "d28eb7b397e011a7df8292dc4f40f8fdb41d1d72e06aa9d147117c33f80550a2";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "71deec6f84e5feb162b8c6d3a7a8682f27861cb8bd9faa57e5c0da494926c82b";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "fb19289f317ce9295958205e880750f49980f7fcdf54022972163d8b89b9a557";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "d2628f5e0f6179d5c8a7dd3c84577782b05704e74f5ec2e4c3bd2e8cbefb0f10";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50703-1697730.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "b9eea7f7418e0d8c97c50bdd5eae2ec3082cd164715e1c8492d6835fb13625f3";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.30-1697785.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "697a006233b8df36ee2e6846cb3a322e24466999f2ee1a866d4d61411f6769f3";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.30-1697785.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "d943d267680c2da039cdecf14da6c4afb1d34b9afd2903b3296af8dd93053f7b";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.50703-1697730.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "755d75c8a0fbdec84cbbf6a32400e1991ccfb66c4590ab3a8277e61ea0b0c0a3";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.30-1697785.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "e90f4d70ec3fae79b6b83d5fbf054b3f774996b21216c66b4ccedc1ac6b0cca8";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50703-1697730.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "75baf712830ab1563690efb1c9c96ede4ad2623b1f0bcfbdd5883430f9b1ece1";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50703-1697730.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "c9ed6f6365bdaa100e1b70ee6aa835bf66d3064858069dd7aa8b09e6c523910b";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.30-1697785.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "adeb057a24e40c5cc030ae559f96e2c067f9e32aac0c71b29a88dcd24a229274";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.30-1697785.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "62428952667761043a7d6f43ba2cf191f35c85a369ca91609e6d6d18c98b6865";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.30-1697785.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "d7305aac20d5ba549a8ae22905b6ea1a83897af683f202b83ed26f48d6851d0a";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.30-1697785.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "deac300ac8d4194d41bafe4ee1e5c57489c14f65f6aba5a9bbb5e594b7c77829";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.32-1697785.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "2c47944530b7f2dd282ff13fb77f11e30baee92df0396218fb587a783dfce56f";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1697785.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "e692be10e1b5b5d80f54049c5821605fb4f3f0f3e1c277a43515116a6b528935";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.30-1697785.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "a071f5b7d715b7868d45806d3347cd271fa5623a81565c190140c08fba31c9b2";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.30-1697785.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "d82cdf426c3ea04d2771e7a8c742e2eb7cdf2dd6637f6b11190a4af8d43d6600";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.30-1697785.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "8c422c62c323a43656fac6054e39d1d1986ccb01735967dc09c074d7855451a8";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.30-1697785.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "89b1ee47e77bdf54fb0d12867fc00757bd150207297c90851da046355fe859f0";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.30-1697785.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "64ef89f88f690788baf62f40509bd0a75255f6f977c4094e0252d739367d8085";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.30-1697785.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "c81e7c04970812def5b013ecc424b888583c1996852c624f07013ba6dbe2d138";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.30-1697785.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "820d6f8acae0484626c81959502358daa44525fae67db895287f96f872f51687";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.30-1697785.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "100f41d2937e9b9244f41c722c56615e641fe6fe9c8040c1a0e606b07421a09b";
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
      libllvm16_0_50703-amdgpu
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
      llvm-amdgpu-16_0_50703
      llvm-amdgpu-16_0_50703-dev
      llvm-amdgpu-16_0_50703-runtime
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
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50703-1697730.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "673122a73f82ae4f7b2e8573401c038eb3c216b0f63207e717d4038a7bcfdec5";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "0a788d501167cdf05356d1e7c89cb9904e020eb3f6c791db8e81b4067a4aee0b";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "45ad99ee6f8c2e989487ae6c870a7bd5555202e397c026ddbf3fb54b558da480";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50703-1697730.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "5dd3762e8603999620d93ca6cc2ab2bf667c1aba7633ff90469b15fe64ffd993";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1697730.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "6a5601f0a03d52feb2f99defdca1d53d6266e86d6172a63bb48f61fc9fd1f05a";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50703-1697730.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "ab0f5d80f6727511612b2992204cb65e33e5b3917dca68ebc6829e4e2d66b43a";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50703-1697730.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "340ba008f02b5bfaa173055389a673551ba9014561939cd8ea0d35bdf82c6897";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50703-1697730.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "ed808cd1c7cbd5d9c2f4899d5e67d3a5364e8911be50c462bceb81c23f4c9791";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50703-1697730.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "3f86c3bf1340b2e1f0ec50ad5517a920ebdc0f62c93cbe5236925b6a11d85bc2";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50703-1697730.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "531b1141561fa7446b91d84540414ee703c1556c201d49417f6f156e5f75c292";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50703-1697730.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "e7b346efe8043cd512103be66311d9f7a1c909eed2d9536345b3aecb269f8721";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50703-1697730.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "2e4c5f8e8f5da7d1fcdc280ee10add2f6b25d354f990572ddd65a6ea480600fb";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "c20a79f8777f7d3443f00007165a2b34c926eac0c930e0a2029bfbf4aec93bfb";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "9c520513c5b4c6d2d3da8bbbe93f8f5fa52fc1a6d252acd13b450835da169472";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "7551ba52427257652d24084740ebfff97a7a7ad05789a9df51b164da932422a7";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "7d28d1e90b7f709a181ea53d9cf6ad1c7ab7714c45f811e065a78657a77fecbe";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "205426c5ed46d5504e295da0d2dd02a66abec93c7005874fb382488a8e998ba2";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "e617f186b2c3efc302454ef26163322415dab0bd5c4f2b9f8f24692149237040";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "9527b44c37fef2a077f6579c0f65a8b4a0edab6b32e0136033cd2c5ad70fc2a9";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "2dc421370c978f6fa47dced546e19a4feeebec418c0bcb09df4f82f4e2adc7c9";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "44febe11f9905d4b0ce9de96088bbd2dc3349690839c116fbef0e7d89751cc54";
    });

    libllvm16_0_50703-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50703-amdgpu_16.0.50703-1697730.22.04_i386.deb";
      name = "libllvm16_0_50703-amdgpu";
      sha256 =
        "1951dd6bfd45aee2c2f8abac242252492265f09e8761f10042c20831ad76793b";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "6bd2b10cefe174c23f237c722d8b4d052f190c230676bfde7f62970184b02980";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "39aa72fb485dd24a3d21b04550c9ef8f6217c96ab50ef177c6e580228eb16836";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "dbf8aa3333d1b59f2045c49d52a7ad0f7416005ecb27d737c1fd9d05c0bf6218";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "a05b12b203eb018e70da3f84b98a6271db22363ba5102f81c5fa6b88341b53bb";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "48802230170a7b186881fdfdaee63af1e2184bdd2bad999ac222c897718d2cfb";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.50703-1697730.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "ec361274e39befcc6e01d4a3b4ab4952822fc9202ee646e6d4a21eaeca41abfa";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "6af6249f79cb23a10ad6cc7cb3fa2baf9cc0b2a470a6d80299a0764a76aff2df";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "f37f0453379bc9ae0ce079ecfed7d5d06211279a2259b49b0479e1b3764f8add";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "d33580aae381c1f8594d109193faed0003115b04d391c2bb928c87307988b0a0";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "1ac8c3046d789ace6893ad4ffe211f1b98b6155c8c6cd2028744ef7b69fe4858";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50703-1697730.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "455d1ee4e79c11545888dabeb39429e4bf6774f52e2d9b5b58bcb4e0d0fff897";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "40510b76f2d6a75546dbcbc9082dbcf49a52c8e6021c03f57eefac5433829e73";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "3bd7ad3b82b6d69a5d41c8c1c6525e1637101344d781b1a2a3f9b52a1fdd8a07";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50703-1697730.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "6c4f7f06cc08c6501244f9cf42289fb49fd7fe4e9837f835cfc517a7b5dbf2b6";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "0b37498549f51212c8f895336756a842ea66d9cfd5531af882baf470997c36a5";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50703-1697730.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "ea6a3f27fe83cd960898256ad0a18b732d97a70f23896384e0e84917a2b661d2";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "9d8d94771bf9ab447621c071bb270eb941cc653087ec48422faec79679aa0c10";
    });

    llvm-amdgpu-16_0_50703 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50703";
      sha256 =
        "cce2d4abd2ef82a73d0eb261547fa52294f855173a1cf5ad5deecefc1b55ab90";
    });

    llvm-amdgpu-16_0_50703-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703-dev_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50703-dev";
      sha256 =
        "5633a8b56991f3b4cc1b381999ae53365cf2ef35c04a4bd704f90e5ebd466051";
    });

    llvm-amdgpu-16_0_50703-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50703-runtime_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50703-runtime";
      sha256 =
        "68a7162a392b641d42fcdca4f71e554afd1bcbe511a5e2782792d1dbf839f931";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "7564bf1ef9ceb68f23ef9749d69e5421f00fb9cef48234193d87948580ed0700";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50703-1697730.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "fdc6b91c6cf4c4f6f5828e8a572f10ed9fbab6a39c8fe95b420720f7c12d8b30";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50703-1697730.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "40e5b89411b405b40ffe64ed0965e989ea0150aeec2549fcac20aee62c5019c9";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50703-1697730.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "82d17ccc5a46d6ccf39bcf14d5503cd964ca3d7ea6c603bc1d4c25870dba04fe";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50703-1697730.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "4a904f3ca0c4c7f01218b69b027a6cd9f2e07d8cf203ede86f989e1c23f1d8bd";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50703-1697730.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "b0e2f758b7b4f02d9ec8d8f5ce8d7ba484a4eece44836b4a293d8ab93d38f3cf";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.50703-1697730.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "653f228d16d8565150655f2436403badaebefcc3b2611cfd1f8ee5e7ba9363de";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50703-1697730.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "75baf712830ab1563690efb1c9c96ede4ad2623b1f0bcfbdd5883430f9b1ece1";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.30-1697785.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "62428952667761043a7d6f43ba2cf191f35c85a369ca91609e6d6d18c98b6865";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.30-1697785.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "4e6022fcf80cb1bfd2e897d3057dbf851d0b75e517b396c6ead2c40716495684";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.30-1697785.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "7a8c2077304c6640a23785634d8051130131ef3f515cda6a7c9186c229b25fcc";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.30-1697785.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "952970c9615183bad04f18e60106b9bd4243d74536c2b5517319ace024e31724";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.30-1697785.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "e186895fd49d53479c4205e99ea4e47b859fae2a54b241bf124987b3575400fc";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.30-1697785.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "92601e8b5f6bbbfa440dcb1122b6900bf1615b2dad9969c64ad6d31c20b0e952";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.30-1697785.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "63186e3a99f1f7c47d17a5a3d237bf35742cb87830d3d918fc401be84784eeb4";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.30-1697785.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "0917adb9be8e0f471ca94a1bf35c511731f24741164cd1077d5126b80ef7b97f";
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
      libllvm16_0_50703-amdgpu
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
      llvm-amdgpu-16_0_50703
      llvm-amdgpu-16_0_50703-dev
      llvm-amdgpu-16_0_50703-runtime
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
      libegl1-amdgpu-pro-oglp
      libgl1-amdgpu-pro-oglp-dri
      libgl1-amdgpu-pro-oglp-glx
      libgles1-amdgpu-pro-oglp
      libgles2-amdgpu-pro-oglp
      vulkan-amdgpu-pro
    ];
  };
}
