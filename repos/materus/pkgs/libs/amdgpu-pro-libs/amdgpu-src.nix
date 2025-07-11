{ fetchurl }:
{
  version = "6.4.1";
  bit64 = rec {
    amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu/amdgpu_6.4.60401-2164967.24.04_amd64.deb";
        name = "amdgpu";
        sha256 = "fc201a0e1121f12d55aeadb588c1f76457f3071f607d50cc35351b13ac6b26a7";
      }
    );

    amdgpu-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60401-2164967.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "452855e298e2d3f9c92cf63b7bb6c6fe893dea7423ee0da13513294060780a6f";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60401-2164967.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "d5d5d404cda06d02855e2d77bb35045fc83f968bb5625964facb18b7f83de873";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60401-2164967.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "24bad7d3d571516b2c143df4af335818c21b53468277c688339d9189ef19bb8b";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2164967.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "94d70eadc7c4a3bf068eaeff712975cfe224eb3164a7e6d32cfaf1f3fc315cf8";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60401-2164967.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "84f6ee05680566fde834499a7dc4028a761854ab47ccf40d477203e564366209";
      }
    );

    amdgpu-lib = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.4.60401-2164967.24.04_amd64.deb";
        name = "amdgpu-lib";
        sha256 = "d5b1f02dc99b9d3d93e0f45b11c4ab9b645299ace431271727241402395f93ab";
      }
    );

    amdgpu-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.4.60401-2164967.24.04_amd64.deb";
        name = "amdgpu-lib32";
        sha256 = "d1fc8d07f0d5a72b10360db02c85ecf81b4c4f9f7984d95f50804a6ccac4d1ba";
      }
    );

    amdgpu-multimedia = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu/amdgpu-multimedia_6.4.60401-2164967.24.04_amd64.deb";
        name = "amdgpu-multimedia";
        sha256 = "8f8313cb3f93a9da2c8424ee8487b18ed0c8121c65b04d98cacb14365d6be127";
      }
    );

    hsa-runtime-rocr4wsl-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/hsa-runtime-rocr4wsl-amdgpu_25.10-2166611.24.04_amd64.deb";
        name = "hsa-runtime-rocr4wsl-amdgpu";
        sha256 = "6d1bd66ca745de5f0772241ea34b2f41cd1516a879fd30c8af1c021656bb8e0b";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "84353123370372934be3e3a51d19e2af98080af2a44c7efadb3a65d377dbc895";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60401-2164967.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "a6db66964ea12d58698799da11151495cf217bc58101ab789a0953a40399ec48";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "e881743b24be80a51e988d6b57676f428b44871e31661f16f941eadb5690b66d";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "eb81b8c4c911535a39929ad8c01e8ea151cba0d62a2c94841e92f12d5b663f0f";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "9c3787de57dbc656c317345eab8d08ea68f869ee7a26c96bc29d7016d30c3bbd";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "4476b144bf2e177e3751d17dca62647478bb6768691c2e0784d2ee490ad12536";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60401-2164967.24.04_amd64.deb";
        name = "libdrm2-amdgpu";
        sha256 = "ff70cc3be6da55d59ca505bf1f013f8d226b896a13ffcefa17ce7086d40965d0";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "e3256170fcc1050e5f177138eea6221bb425f5f8ad4b585ac0f0fb498582e8fc";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "0a7008a2a08edca33919f65ed5274f767bae283b936f781cbd952832f61da175";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "3c7c0ea2dcfa13889268cc79dc20d7379d4205659aadaef7057842ec60219536";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "4769aef74ed2d8553bfba3e318a151f17efa581b9c98b8b7deb05e7fa6f815e8";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libgbm1-amdgpu";
        sha256 = "3e0d57d0e53d2054e7df3edad01c177236d26fc6ff9545aaf5ac5628a6b5b926";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "62d6217a547f1a8d600f6c17f291d6e2ffd6f9235a8e9c7a50426508bb3fa42e";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "51255c526385b670d6412d424a47d88d5cadf226bd3ee410def85663881a96ef";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "ffff893a0e8cc7782cc399e5f00d57babbdae73c29df979f041fd3b7dabcdfa3";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60401-2164967.24.04_amd64.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "181c8f32502f32e3b0595398cccac5992c8635099e279945da32ac2178c173c4";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva-amdgpu-dev";
        sha256 = "347726ef38c261d7b3a23570fc302053a8200c1f1c1abf764cb2c9ce44524081";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "fabe42bb4dba83c27c70b6c2e724e74add88903be6c954b4ae13d7acc5d4b5d5";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "a897acd0097f40507ced6b3aaf190d75cfd27770eecf46cfa863aa8ce2c5ef2f";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "4e9bd9ec744be3b25cc7ccb2b232e4118fa8e88cbef8f61ac238502d326f48f7";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "56a146b9597286928b6bb2b56b069e1c677cc444c46ae31d7914fe41b78b60e7";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "libva2-amdgpu";
        sha256 = "a3e5f7acdbbc21bd0e9315727bb3e4fa5e03af0c4471cf6eacd7a5c33f3a1304";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2164967.24.04_amd64.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "43d9e632e6a9feb44d2957b08e1715ad3831b0a81f9bc5ac6415f6fc75173a39";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2164967.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "e22326e6f37661ff765863cf420f702fb1062492f36ec1065e140603c935bf16";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2164967.24.04_amd64.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "61e49cbd2a8b3f03157cf97934299325914cddab3fe9174bee58b30582f66389";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "c48d0bc441454b911c5e3cd31345ab410e8f905ace0375c2f1a278bda81b7bbd";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "1495782cb3c725b2865449db553604529374923e65461ef020cf65810c9cc49e";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "8ca729fbc70253a5e70508e2ebb68dc1eab5889c81d73bcef21e61d46a8db81f";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "6907127b8ff120962d0e2791bc846910e07ae8ec956bf6cc2a33009622bdbecb";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60401-2164967.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "f97c63a2330375e3bc8dd8522a76e1a21ee6bd083e0c36b0c8dc22ceb3cd40e4";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "fa0a4a7aecc934340ba254d331a53e20ff3778e299eed3ba7f8f100deb5b1353";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "2249513865e45828b4be3e0e21138e267e155f121e7f790278f87a1e58445d2e";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60401-2164967.24.04_amd64.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "55ba24dd6ff40d11447175ab01ab11573ed495dd84039051c6190378b5ccf3c2";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "114216d484eda0551404ab4b98842b60037b8e659ff741cf5122b7fe7e903852";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "83ce03e2bb34e2d1ccfbd5df0a627312137b10fcd65073a2f32c4e1bda9fefaf";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu";
        sha256 = "a461c4474e258b12e7e97adee27b59a702afd17a46d6aaaac80040f4c9e227e9";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "99fbde6f56765e34ed20a2c9242ea0960f9517432d1ad5b2ba2f6c100c385d5d";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "734b83ecf5154cddb11f9615629cedb40f44abc6748c1680f6d4e94ff3aaf959";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "a762b1e658210a7945c38ac2ba0950ec7f56e51f758c6e5d54cd956647e5153d";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "2accda417a0756d89e3736b22e1926ca344d48b1dc1bf0d3b6117024ca45f906";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60401-2164967.24.04_amd64.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "c3f18e3fa8848c9340550f2bef4985ae33effd49615bdb1087fc6558c792dd7a";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "9f5a8c80f8b22b0cb3ca9c487062a59751540868648af6748c1b3d1425cd11fd";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "b11880da19d42222f21ee64d337088fc0635556519da6d6958ed4e9fa6030bd1";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "f255ebfa094c0318b41c0a145b77335fa8d7cd74cb774c71fd9174388dbeb610";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60401-2164967.24.04_amd64.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "70c002db7b3d656e61c1a34994ec10942152b727c15e46cfcd05a32165ec5a92";
      }
    );

    umr-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu_0.0-2164967.24.04_amd64.deb";
        name = "umr-amdgpu";
        sha256 = "04a9d12a309c766c77a53eb163022cfed51fe32275d250272d09a85ad7412e30";
      }
    );

    umr-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu-dev_0.0-2164967.24.04_amd64.deb";
        name = "umr-amdgpu-dev";
        sha256 = "1b152cff5eeff965487b0325627615cf64dafa8932fcec2fdf04d0942ec781f1";
      }
    );

    umrlite-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu_0.0-2164967.24.04_amd64.deb";
        name = "umrlite-amdgpu";
        sha256 = "475777885375511a5d22da5184005252b539953d5aeeca93dbd60b06bee8fca4";
      }
    );

    umrlite-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu-dev_0.0-2164967.24.04_amd64.deb";
        name = "umrlite-amdgpu-dev";
        sha256 = "0c37e7536a96e6c98a993075aa61f457e4b83a7aa91cae6d835b155bee96e907";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60401-2164967.24.04_amd64.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "46ac37dc0c47dec4a4d43830e356b20694d9a3c1f8376565da83853772cc3bc6";
      }
    );

    vulkan-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_25.10-2165406.24.04_amd64.deb";
        name = "vulkan-amdgpu";
        sha256 = "96efd5dce9b057fd5b023664f47dda0b7a8450275fb88515d61988c71943a02a";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60401-2164967.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "cc4f51f5b54a7cdc19d6cf90b9b3bf4f85196e9596eaf048f58d5115c6bd3a4c";
      }
    );

    xserver-xorg-amdgpu-video-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60401-2164967.24.04_amd64.deb";
        name = "xserver-xorg-amdgpu-video-amdgpu";
        sha256 = "2931b04a71c7c3de6838b1d7ee5c79d5981dbbf9edc17fc37af5ae10917d17a7";
      }
    );

    amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_25.10-2165406.24.04_amd64.deb";
        name = "amdgpu-pro";
        sha256 = "fe5012cec071a5b3a98dfb3ca375899f7b0e35bd67d3037fcb3cffd42b8beb12";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2165406.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "5e4886d05e4a4091d8ef3fbb2a66e756879746045700aeacfd1519860f793a58";
      }
    );

    amdgpu-pro-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_25.10-2165406.24.04_amd64.deb";
        name = "amdgpu-pro-lib32";
        sha256 = "4c516e738e67d8f7dc7bf6f24861342c0e5e9817402eb00d34cb9d01f17c9998";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2165406.24.04_amd64.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "453f584bee9671480ce612b6e43e47e074dea7671e1bf978bbeb251d65a12770";
      }
    );

    amf-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.37-2165406.24.04_amd64.deb";
        name = "amf-amdgpu-pro";
        sha256 = "5337682754596c5e056827f962f1aba0b87c2bec484dfc531e2c2b53533b078f";
      }
    );

    libamdenc-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_25.10-2165406.24.04_amd64.deb";
        name = "libamdenc-amdgpu-pro";
        sha256 = "0c57120f4443b6a0380b87e5ae7a3664e501b1dfa5b4b00bd1e17d31f893b13f";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2165406.24.04_amd64.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "2db86f48bdb7cd805c7e722dc4a9e38f059cfb763baf8f4a8fa87fd1e60d1713";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2165406.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "fe24c99a3adf7f251760f618e61bb031e4cf8bc0381a8ad1dbf65e7b7b9287e6";
      }
    );

    libgl1-amdgpu-pro-oglp-ext = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_25.10-2165406.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-ext";
        sha256 = "5bdb156e78a5c48d25d42fac3f174fb41941256344b51ec0dd7386c32e6ffbd3";
      }
    );

    libgl1-amdgpu-pro-oglp-gbm = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_25.10-2165406.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-gbm";
        sha256 = "d757bf5417b886970aaa58965203250e71f363464efa4d50a15526c2b4f64ed1";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2165406.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "9ac69396030fddf3efb4d5922bfc964212a7670201a9d908a67b3e4b614f8de7";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2165406.24.04_amd64.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "283f9fd992e1178c0fd6b4102437cacc824213cc85748a11f931e3dd1949425a";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2165406.24.04_amd64.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "eb7d36de1e5e3c799fd7a392bd296df309a35bad437d3e0875472a75acfdd452";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2165406.24.04_amd64.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "36a93acc4c88bc2573c2a55a84003477de45cf0c9a6f06ef64842fefe697b895";
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
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60401-2164967.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "452855e298e2d3f9c92cf63b7bb6c6fe893dea7423ee0da13513294060780a6f";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60401-2164967.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "d5d5d404cda06d02855e2d77bb35045fc83f968bb5625964facb18b7f83de873";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60401-2164967.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "24bad7d3d571516b2c143df4af335818c21b53468277c688339d9189ef19bb8b";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2164967.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "94d70eadc7c4a3bf068eaeff712975cfe224eb3164a7e6d32cfaf1f3fc315cf8";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60401-2164967.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "84f6ee05680566fde834499a7dc4028a761854ab47ccf40d477203e564366209";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "23297ddc6a7f4483ea4f04b80764a42a066ec8200c663bf8f58287ba38bc6f01";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60401-2164967.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "a6db66964ea12d58698799da11151495cf217bc58101ab789a0953a40399ec48";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "834293a5f8689a4ed03e1bf245f2dcd6aaa27714d176ec65606d1ff9c0a00ef9";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "247c86bbe77af0993d0bf9a03768ad2caedf96ab2c8ecdb60f871f90324f400a";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "b8dc50f63065d7ab4eee8c238466154cc8f09cbd18b89d5d37fa211e152bc443";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "baf7356ee4fb2905a8342732d6882fa579d53ff4ca7293c2815ad5304a251865";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60401-2164967.24.04_i386.deb";
        name = "libdrm2-amdgpu";
        sha256 = "ed09fc185b232b25f1ab88d8bc7c359f3295bb12298bf9136ba26e98988bf8d1";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "6f9c262d0943b87ca8414620e425e985af01b01b6c670e5e983457e8a05d14bb";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "4cad30bdf070b0453744dfad79481f4c6ce2662e510009bbb939243475107e41";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "f584b6899422ab66a689df53a181895bacdde091a2685ba22bd27c0b31ccfb24";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "903bf61298739e0dabcc2de4e2af1d02c51335b30f82743f9aa0eadbfc501346";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libgbm1-amdgpu";
        sha256 = "8c0b87ee54c98f427562240ab07cfffb5788bd123c94681f305995d12ed11a04";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "b0e9c1e4f16704e246fef38c6cf388891f786e0438a47cf6f5ae6a072b99759c";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "21bfbee1b6d78d04616010488fad6b050bade918133e224c5345b601c6798f76";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "b6773f6d82ba55025747712f1b02689af35a5bf696659e8a68007ebd5ae0df4a";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60401-2164967.24.04_i386.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "8eadb084d0f958522b9a8302274f278109ca5855e1887aa6cf4651ff13f5bf47";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva-amdgpu-dev";
        sha256 = "239b4f1ff58353674c1af8378134b9d28cf14d20d113c534c660818a7044b537";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "cfb5950ec47990830b8f2caf493d60da685214d3a69b7c91bfa5cc6ce3aabba2";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "e937b711ca743683466d20399c875f97ecd12a70ea69a488d322dde8606b9791";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "259c225ab9ef502e91c117bbe25f205b90e3acd575271c9731ccc64ed267c66f";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "616bc3e18b49bad286b1f14b0917cfe8c5254d312e9dbede8cc9ed94622ebe84";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60401-2164967.24.04_i386.deb";
        name = "libva2-amdgpu";
        sha256 = "f1b4c4c4b8146684e2a03ea1224c26d6fbe005a7669d836e75cbaa3a44c8f26b";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2164967.24.04_i386.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "c560036b256e7809a61e264d51a735476be241650b1d7f43ec3c5ead3b66125c";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2164967.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "e22326e6f37661ff765863cf420f702fb1062492f36ec1065e140603c935bf16";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2164967.24.04_i386.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "5c549020aa884f95e8e37ce5653f136e4084b76be62dc013459356be35b6c449";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "31bbea2963d530a6c2a358fca7daa9bd7a47c1b8cdd880907a2837036db9d746";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "c2e86e507ee28d092b9cd6a03f607f2d757662fb32a4a1168ce81d7a5fe68ec9";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "2653f1805a4cf824bbf8dfb8ac522c4c758346bc1f61c7ed2c3ba123f8c32890";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "d459d272ae890d30b923d0a2e29e352234ca3deda26bb2116fd77c95839d2523";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60401-2164967.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "f97c63a2330375e3bc8dd8522a76e1a21ee6bd083e0c36b0c8dc22ceb3cd40e4";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "74c0fd2203de6726bb057347b506fef3efb89cd3ea7eb58c6cee9fd7233f49b0";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "f30198396799f5c3b8d75af1d0d01ae6125743f65e0710afe4f0dd8551d374f1";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60401-2164967.24.04_i386.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "bbca9e371ce910ae615018b660be66cf706fda796750e5c77b27fd2bd45f3bf9";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "9e82e7b9af661aab51e45d99efd84470b7d00c8d8b4813b88765b6e920717610";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60401-2164967.24.04_i386.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "9e3988783ea10c1e611330f5e1ce678cf176e76edbffe08b5c08da92795665b9";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu";
        sha256 = "7147f9c97fa4721eaf6d8c3cb15a3a90b7a19e4e50f492b17df0845ff8b13ca4";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "a1636265e68e565792702701a0bc0d95289fd49e2bc9e8940157e1c3d513ef41";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "b0fdc346f3c35e785f0723179aa5d9c15b1487712913bfcd1b0eb7be12038f87";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "710e99eded5d855c8106bbe200d47245ed2e7f0192b5cc4bde5dae73c9da5077";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "002acb72dc1ac607659693daae31a10ee6f72127459acbc53f33c998d1c3fff8";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60401-2164967.24.04_i386.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "1e504d8b6a80be8d65018c1aa5f37eb861216c87ceb44354da23a95a9675a51d";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60401-2164967.24.04_i386.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "496bd90a5393bd004fbf3568898d95275b0ec56075dcdbcaf7ea1c79da0b36a9";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60401-2164967.24.04_i386.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "2bb7aae70c265398d8549eb3f2b62d3e11a23f68ca6c574519510b464b97c3fa";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60401-2164967.24.04_i386.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "dfa8c5f895dc16a455640b023cadf231d8ddb16b0d8939a81bf5e3827e32690a";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60401-2164967.24.04_i386.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "bfe3637560bc8b07bfe1731acec15c451698fb8fa97f3360fbe1ef55d74f3f01";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60401-2164967.24.04_i386.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "70d4946dcb7aae41a1542af3550fd89f9976e877097a7034b6828b3aefaa615e";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60401-2164967.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "cc4f51f5b54a7cdc19d6cf90b9b3bf4f85196e9596eaf048f58d5115c6bd3a4c";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2165406.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "5e4886d05e4a4091d8ef3fbb2a66e756879746045700aeacfd1519860f793a58";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2165406.24.04_i386.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "e18b8e198c19c856155aa33ebcca0024155709157c2c426d776aca381574973c";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2165406.24.04_i386.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "0fdb637b011880364d417d44481ba880bc443c4ee10c7dc4de80baf4c24587f5";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2165406.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "021e0b2da4ebb62b36dd359306e46cebf59a7af16a5588023a081471a14137eb";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2165406.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "db3ece0817d757fdb0690bb2b98db3d9ac8494c0b180dc9e57092e786dc84289";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2165406.24.04_i386.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "ceeb8816759ca34b24066f34fdc19fb2c8958a57d3df32dc1819813d5e7055a8";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2165406.24.04_i386.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "ac3e6aee6a910d0bdea995ae3a8cfe36b1aee1c8c52290285a0400045ba845dc";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4.1/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2165406.24.04_i386.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "2c3dd9ec9787d4f8e8103daf1fca6f472d782eaab8e9f30aabe8fddcdd36887c";
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
