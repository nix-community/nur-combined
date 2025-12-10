{ fetchurl }:
{
  version = "6.4.4";
  bit64 = rec {
    amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu/amdgpu_6.4.60404-2202139.24.04_amd64.deb";
        name = "amdgpu";
        sha256 = "57b73fd4b25e7084c322206596c19fe47ad4b10e92a6cdc52a8e3c3672638818";
      }
    );

    amdgpu-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60404-2202139.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "a2b47ad53ac5b481e81a147bc1070ee241d32f6a719757587f1f7bbc45a41859";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60404-2202139.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "9da6d3a43fbd146fd37c585c8e8a010dd2a5981d6f2f816591997ca0d6e5d501";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60404-2202139.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "72eb29dfdba9b6cd4bccc34e345a2079a2c8840ddc1febf99ff463836bf8f2b3";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2202139.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "24e239eaf419c11414b405c68092210029a6cc8d8cedf21f1848afb7bfb3943c";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60404-2202139.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "532506af45c89516a2bd54e499c60a7b10f5438608b6e11472fb45e397d70b3d";
      }
    );

    amdgpu-lib = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.4.60404-2202139.24.04_amd64.deb";
        name = "amdgpu-lib";
        sha256 = "c7b8e3a388833adfa7a70ef92fa2561f133245d5cfcdb59809fab83dfcf3e918";
      }
    );

    amdgpu-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.4.60404-2202139.24.04_amd64.deb";
        name = "amdgpu-lib32";
        sha256 = "5f1f3e1a394aeb4cc7ec1d99099131848c562346f9e68fb19646badc410350fa";
      }
    );

    amdgpu-multimedia = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu/amdgpu-multimedia_6.4.60404-2202139.24.04_amd64.deb";
        name = "amdgpu-multimedia";
        sha256 = "ff02536cb6bc96d7021ab247a5dc87df8c7e703fe49ff988dda78bd764e63fcd";
      }
    );

    hsa-runtime-rocr4wsl-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/hsa-runtime-rocr4wsl-amdgpu_25.10-2209220.24.04_amd64.deb";
        name = "hsa-runtime-rocr4wsl-amdgpu";
        sha256 = "e353180103db2840567ae69a98c11e583cc41469f8f91fef89f2acaaf41e2517";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "5375f172e8a0da77fb0c4177c09bfcf8fa0c2744ff9ef33192a47544691b388a";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60404-2202139.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "0bda1787a0fd55bd526b4a3f9377a79a57ff17dacf7c8fad1695c9c2ba979e5f";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "738f5de339fbd5fa149a50ea04f2caa28c7a55a981277949bea32ba9d86c2ff3";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "e483685fa714b62d69b6ae163b4f09f916749983ee7c6e6a4d115394dbdf87da";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "8ed2d1f5cc5575d27215d77ab9b37e8c2437b5f479da2a0ac58ee7c64e446c32";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "1074940956984ed0ec6dddbe4512d4b116d688407b4afdfef45805520193fbb4";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60404-2202139.24.04_amd64.deb";
        name = "libdrm2-amdgpu";
        sha256 = "56e167925ea27f0d7f38473999cff1204edff7642c6bb1d6a94aefa71aa8c1fb";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "c0d1691e26bbf93a630c3e1632e4a049c27dbed9cad85c5b32d3c16b8fa43f64";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "8efef645cd85d7864a7b6810cf11ee84786de2b9f11521300108dde64cd5b7de";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "255033f8bff62079154f50fd0defdc97b062919076b4db386dec1c2da864688b";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "3f3060ecee32f6805465b361e7168c052a6a0e282decf8a3dc3ff061213a162e";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libgbm1-amdgpu";
        sha256 = "6d02d0a0466b29a8f8a88093d682f0d1da8ee547f698e4651f1c94c84b06cbb8";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "d07cc355c3d92a7b9adb0ee0edb201f9d61e6f08f936cf8de05959f453ad0a54";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "3e8bde21007d3d7fcc3329d54f4308a49ba4322e17d5f8d9a4fb0cae2fb38a9e";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "b02f1b7a435d56678d54c36a78b2cace5d18c77e3c3f20da754e919a8cd379db";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60404-2202139.24.04_amd64.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "8356b2a1500365def890b74d7dc0b12429b80df0a1c4f5fcb9c36de2316bd9b0";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva-amdgpu-dev";
        sha256 = "d4df8dee28b8a7777aa64b9c2b11d7ff52c900a01ba0088a869e817e460c28f7";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "7a4454f82367132141b2bb7622805c5d04ab051bf28593aa325ad2e2a9496449";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "2906bf15cb8075be5c512fd0e78d0080d8eeb1e40493f1f236817e8ea5050b12";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "cccea0536e5aaa7fa35a4d2b6652b9938361ce9478d9928e816c610dba6560b1";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "d4acc1eb77e826f48622c07d0f7fe0d613616be1a4f72f1847136809fd3de5c4";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "libva2-amdgpu";
        sha256 = "82495d67baa1e45d4e1923ccf81bb2db8ed78e0b63db0027002046036055de31";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2202139.24.04_amd64.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "f102aa9327d09ffbdb4243ac55110993f96eb3f233b30b53c4ee70c0be0d2a9e";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2202139.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "2c5080085fe271c15e62471944548352c6ec04a5fa9021eb6c73fcdde93aeb04";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2202139.24.04_amd64.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "632f2b96195e61bb8eeccbad03b6d04c27356c39952425ffc7bec194ed070760";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "652d93ee104d2ab04883e0fccf9ad0dca21ffc33f36a7f29949a90413651587f";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "e5c563e7fc88411a082a77971ff4b9a493f33b4ebdb4f2ccfff50515c4902e3d";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "e79b80e51d8985d5bf7f95b29b35e8d3cf9e9d406b45cd12b16dbad4a284e8bf";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "a3d58fb4771a2cc37cfe47afffdf41aa8d0eb364ed1fb7fc3efe448fad7a4803";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60404-2202139.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "d131a244b36f5592ee68c040fddaa2ea69bb47eccc0851c7238c0d2a33c92631";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "c0721aa2bdcdf38cbabf04bb7c7b3fede84c3c284d8e10766f5b2e06280c2e2d";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "b286ee1c4ca2cb0d25f0802271a2590744ccf80648f8ab3d7b35b3e9cbdfdc7f";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60404-2202139.24.04_amd64.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "592b442c7ae9b9e5cc4fc6992ec47a903fa0da4a9a894faf0964972004ea7480";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "2a4e3ca10565f34906f7c2a937936c9b6f159f4805bc0554371443042279f25c";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "fa888005c9e55178c7d3d7d5845b85f0dd005672f57cf11fe4d85131334c80fe";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu";
        sha256 = "1bab53672e81bc89ec5e6f337e5e43c079c5f1a3dff1d2349eff24be0bda0fdc";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "56d6fc0e5101fcc7930a2c993206cc204ee0111f60fd71ecc9f88a544762a81f";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "43a84cb2aa0820198997d51395e50cd346fd327a1433cb38f6298f6b851c06f0";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "e379849dd6dc83c683b350d646ee4c385071db0f4da952150ba146894c2bb571";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "da580dd2d82d7f80baab8279b03110235a8ef2a7029c8c6c77e6cb90f1d3e36d";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60404-2202139.24.04_amd64.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "554bf72a238f5d8a65956090d3323b8af2a1c803077dcfc2f1634d603f4f0b9f";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "8d084640b8e1a7be0ea5040a8674767c07dff48e053bb44513935601fd8e474d";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "0b7f52a708918936754a8317f618448977e933d9c272982a6b0d4948d39e36ac";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "4d3573e02b7c628f95fccb029cfee1581dab83d8a95b59de84e634c68d67cb3c";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60404-2202139.24.04_amd64.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "bc02aa25210cb7210dff5f98e11fbb3da627f1fac83d87484f375982081ca9d4";
      }
    );

    umr-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu_0.0-2202139.24.04_amd64.deb";
        name = "umr-amdgpu";
        sha256 = "ccc5cd7e17e9bd8b4cad80b1d1b8b4ce88d7d2b51cca8fa7538162ddaaf171e1";
      }
    );

    umr-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu-dev_0.0-2202139.24.04_amd64.deb";
        name = "umr-amdgpu-dev";
        sha256 = "e8f293ccb540f8f89b7e3c5745b230f59ceb616757de0ebef4c9f6780581c049";
      }
    );

    umrlite-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu_0.0-2202139.24.04_amd64.deb";
        name = "umrlite-amdgpu";
        sha256 = "d826bc2c5cdacc106d0f5db87426c49d5692ad3a327248c401415f25ef8a33cd";
      }
    );

    umrlite-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu-dev_0.0-2202139.24.04_amd64.deb";
        name = "umrlite-amdgpu-dev";
        sha256 = "6c24abb0178303890320e8d996482613dff73c3be4b51b7209d4ba64b2055294";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60404-2202139.24.04_amd64.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "70aff6500aec06d130403337270b489082a421d6e41f94606c695af06143dcca";
      }
    );

    vulkan-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_25.10-2203192.24.04_amd64.deb";
        name = "vulkan-amdgpu";
        sha256 = "d45874552b97c5e7aafd78715ba0f17e972f6af3cbd80f8c32447af6b8ac48d0";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60404-2202139.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "d387a2dbe84603faf3b7fbaa37ec926e55cf5b60f366f7c1b5fa5fcf98472a2b";
      }
    );

    xserver-xorg-amdgpu-video-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60404-2202139.24.04_amd64.deb";
        name = "xserver-xorg-amdgpu-video-amdgpu";
        sha256 = "33f856bb72f8c1441669a50a2d25187ca3bc077da44daf307863af6d212cff65";
      }
    );

    amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_25.10-2203192.24.04_amd64.deb";
        name = "amdgpu-pro";
        sha256 = "a149bb11c0ab6a55d00335ccb290c115f7cc67c9eecba8c627b8e825a9719f15";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2203192.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "523847f121890b2db74fea9dff2ff371053b70a2a0fc5da8d18a7a4febfac280";
      }
    );

    amdgpu-pro-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_25.10-2203192.24.04_amd64.deb";
        name = "amdgpu-pro-lib32";
        sha256 = "3f9bd9efd6b1accacd9f11421aadbfcf9255bcc399c7ab0727905d5d74f9cc05";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2203192.24.04_amd64.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "af941b61b5fe1fc0d40fec3f1b37f0362e1cbfd5c4d602853a67a120d193d828";
      }
    );

    amf-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.37-2203192.24.04_amd64.deb";
        name = "amf-amdgpu-pro";
        sha256 = "a6496929a58badc0a5451698f632611592dbc855cf518f47e54a66011ae014f5";
      }
    );

    libamdenc-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_25.10-2203192.24.04_amd64.deb";
        name = "libamdenc-amdgpu-pro";
        sha256 = "8c4bc76714f337c4f3649ba8b9868e1b0f7169120d03fcc483ee7ab3fd77aeec";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2203192.24.04_amd64.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "7bbe62db6b7ac62e74f4b7fb9a0e01a00b49bf4c14cf0b1921e4499b62c5a23f";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2203192.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "b220a0f5338937da1908814fbe45c969f4eebfe5e4afd4bf028cc37ed3b0e948";
      }
    );

    libgl1-amdgpu-pro-oglp-ext = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_25.10-2203192.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-ext";
        sha256 = "6fa500bc254a3280475471b68e4db5b9c0d10c3649d81f4ad29f57fc6f415e82";
      }
    );

    libgl1-amdgpu-pro-oglp-gbm = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_25.10-2203192.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-gbm";
        sha256 = "c61700c377a56c5daad896bf6e41f7e01c7f6ff3a8cdd16af5839640ed239097";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2203192.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "a03e6834ab80a38a981ae4ed891ae8c2a9a7ec56d01963d24362ebe5367e5f6a";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2203192.24.04_amd64.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "e0128a3c5b2bf6163b456eb5a6b021547cb7ef703b9158b82bc9cfccd4ae4e14";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2203192.24.04_amd64.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "d684ac235a36b4b07b1b880c499c28cb9e9e1ab017c323d8776a0ec0167c2752";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2203192.24.04_amd64.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "e2627c5144eb38c29f4ef02e2f9d290f435dafd473f85adc1a196543dac866cf";
      }
    );

    all = [
      amdgpu
      amdgpu-core
      amdgpu-dkms
      amdgpu-dkms-firmware
      amdgpu-doc
      amdgpu-install
      amdgpu-lib
      amdgpu-lib32
      amdgpu-multimedia
      hsa-runtime-rocr4wsl-amdgpu
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
      libllvm19_1-amdgpu
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
      llvm-amdgpu-19_1
      llvm-amdgpu-19_1-dev
      llvm-amdgpu-19_1-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-libgallium
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      umr-amdgpu
      umr-amdgpu-dev
      umrlite-amdgpu
      umrlite-amdgpu-dev
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
    amdgpu-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60404-2202139.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "a2b47ad53ac5b481e81a147bc1070ee241d32f6a719757587f1f7bbc45a41859";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60404-2202139.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "9da6d3a43fbd146fd37c585c8e8a010dd2a5981d6f2f816591997ca0d6e5d501";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60404-2202139.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "72eb29dfdba9b6cd4bccc34e345a2079a2c8840ddc1febf99ff463836bf8f2b3";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2202139.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "24e239eaf419c11414b405c68092210029a6cc8d8cedf21f1848afb7bfb3943c";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60404-2202139.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "532506af45c89516a2bd54e499c60a7b10f5438608b6e11472fb45e397d70b3d";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "0cda93a3bcfb12d7afd7ebe31d337de758fd40c8651f9e503656e53400722fb1";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60404-2202139.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "0bda1787a0fd55bd526b4a3f9377a79a57ff17dacf7c8fad1695c9c2ba979e5f";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "b331bb7ba4347dc8dfd37f8f7b97075c9ba87fad372f05b43dd0248039518f74";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "d92090d739fc470998d97b177c2d4a70cf4add718730549ff8594a135e7b6c3e";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "7bbdf372cd6898de3480158c32bb1443d83e40f84ac4e39c7226697b5f774593";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "ea0ae7d7ab4b400a30a6167f1a9e0dcee79e88e660472e1b995d803bebf70665";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60404-2202139.24.04_i386.deb";
        name = "libdrm2-amdgpu";
        sha256 = "fd2f6641401afe33058494ea888ccfb36ced968313b9670c1ae073b58ea5c998";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "157b9bcd63224c032944096464c660fc1f88860fdcf500bb8633da177233afc7";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "ac059a9c137898c896ac76d758557063781ced1d6a2a7c8f4b1bbf4bd59e2365";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "97a6062a400033a32b05f33d167c0b57171c3207f449f2afdab7d9e5b7f143e9";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "45014d4da7564000c842f10044406d739a1843150007283ad0c59534bba44ea5";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libgbm1-amdgpu";
        sha256 = "9931e505bfae0fe534f57951ae5c352d4512d0274c66f7eb91d17b3e49178eec";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "fdaf68778bcd2004fe1f8154cc749a9c8dc54f6177ab583e8c445a40160fb5f9";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "be6cc473aeb71355139aa643765d85a89232289dbb4fe58e7628a0e2bc1afdee";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "0f0e6c1226f865bb24dea079abd4d4766e53b6166ca7e2b5165b2fc6b307d3e4";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60404-2202139.24.04_i386.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "546f7d18dd414d5730f274e15e4f2eccb3d0cd32b060e8e21a30b1b57f62131f";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva-amdgpu-dev";
        sha256 = "077e96aef98263efee43870ed1c5a82b0cd3a175a48c3e6b4a2608239df7b8b6";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "203245307ace72b0c62bc6e1f685de1854331709842fc829bbc5d0a136e33be0";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "e591cbe98f67bf46d301dc570ea975e038b2bf8f2f856d3cc5c1cd4bcbfb240b";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "f8cbd7915cdf5ee84cdfd4d25529796ae24f797437590fdb723aa53fa2447158";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "1ce762d6d445308e4030cd5e86f99ab55658ac6e726701d410c2df6121b12a27";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60404-2202139.24.04_i386.deb";
        name = "libva2-amdgpu";
        sha256 = "edf362b5042c2d566fd670363777ac89b5b668bf4ae87169b3bb883bdf43ad87";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2202139.24.04_i386.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "8960c6119fddbfe3c1b817bbb918ab761b017ca7c589e7b90ab027856f6da708";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2202139.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "2c5080085fe271c15e62471944548352c6ec04a5fa9021eb6c73fcdde93aeb04";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2202139.24.04_i386.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "b4252e26267b3c5039c7570abb501dce056c03aeb76d9a6720fd2935cb94439e";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "64505a99a635d11fa2bbb7933dd4b7b32f252f3378363b0e94c830cd33f1a976";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "e4e50381ee2d89ce536ea784b120eda8ded5624d1021f8cfdba73bd6e6319480";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "644ef8c0127341c46f563216c23c258ba40dd51d7be88d9efca9a6e9c4e83bd7";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "88e0d869b50fb7c2ebf45d51f2a954bc5d5a6d7801b0b71e29982ef710861393";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60404-2202139.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "d131a244b36f5592ee68c040fddaa2ea69bb47eccc0851c7238c0d2a33c92631";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "312809cc8e34737a8078ab5d820151e67abe39c01951e085a1722e7610d7404f";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "6b2cc546b9e5fbab6f76a6af9033c29be9e62743f49de08242a61a6499b68597";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60404-2202139.24.04_i386.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "24f7d384921f23dfec0153531ff06cdefa1f4d024826448d7e0ec8cfcd414e7d";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "85ad4febf0d5730a7c51f163f1e4647f09de6c5b0ad7a5eea7bbb4d794dec01c";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60404-2202139.24.04_i386.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "ee269559e7e56d9632ab14637d36b2f9d28e75d9200e0feeeb304cb061afd9ea";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu";
        sha256 = "be33c4e21820cca272e707c23bbcc0bd625732c2943a1ecae1ac57047d2576d2";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "d7371390532cd49028c29222094196c2e0ebad3b861cc0c4b0de9ed988a6bd9d";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "cf9f134c176fbdb335b5ed99ce7a12e40a35af0718f2c5e5dbf97583919721b0";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "f43ee487787921479d956cde073d0d42813d9bd1fbd87ce95c41441f18e1d6c6";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "cb2372b0bf1d3b758ffc5667fefeaee7fc71c7c3b3030332d3e05885c46931e3";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60404-2202139.24.04_i386.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "fccd347e50ba716e70a47cbe3d3d01142a3a14363f7e00ab472a58d9fd3a1c79";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60404-2202139.24.04_i386.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "8bd07fd5d84b6ece8ac2db23d4bcdd7b909613814f5ac011394f2a5e1fdce99d";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60404-2202139.24.04_i386.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "a7ec051937889798145891732902b62f24ec73693511c839cf518a4228014382";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60404-2202139.24.04_i386.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "07c6bd50d90a37c9d0b132820afc8c301625fdfd1ec516f93e664f86f50b2d03";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60404-2202139.24.04_i386.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "5d80ce69ef6026a05de5a3be44ef9f2ebedd5297abf16402617fb0647c8841e5";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60404-2202139.24.04_i386.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "1f806149625d8899d750256a2493f2abb56410f5fbe7957cdc452abecb0044cc";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60404-2202139.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "d387a2dbe84603faf3b7fbaa37ec926e55cf5b60f366f7c1b5fa5fcf98472a2b";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2203192.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "523847f121890b2db74fea9dff2ff371053b70a2a0fc5da8d18a7a4febfac280";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2203192.24.04_i386.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "c9eeff7ca57658a23cf78056ba4867dcb8d71fa0fa34522223bbf3698d5491a8";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2203192.24.04_i386.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "73a62622cd342502a360c274935b15cf701b49c25a6f863f8ac0b14dd6dd9dd1";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2203192.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "9bc42ac2a5de417e1d7304879d59bef3770ac1fae90e99b21e14535eecb587cf";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2203192.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "333b7e66ba6340a624db9b3b374d59f39677bb483d5d73912a71f5e75c66d117";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2203192.24.04_i386.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "660fbafa15ad8f9756a6747efd9383df16bd42abcb12c04e8e6cbb08dba91772";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2203192.24.04_i386.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "3be92914dd5cac22b63af2145fa295a3d31c883d1b770a9ef84a3fb464905174";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2203192.24.04_i386.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "59680f16eec3b0a84587018b4e4ba6455182cf40d8b3efe1129e7048c197eb41";
      }
    );

    all = [
      amdgpu-core
      amdgpu-dkms
      amdgpu-dkms-firmware
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
      libllvm19_1-amdgpu
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
      llvm-amdgpu-19_1
      llvm-amdgpu-19_1-dev
      llvm-amdgpu-19_1-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-libgallium
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
