{ fetchurl }:
{
  version = "6.3.4";
  bit64 = rec {
    amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu/amdgpu_6.3.60304-2125197.22.04_amd64.deb";
        name = "amdgpu";
        sha256 = "4eb5a4b5d19a09d26c855ad7264650060d5de684d87ee69bdd90de94955bef3d";
      }
    );

    amdgpu-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.3.60304-2125197.22.04_all.deb";
        name = "amdgpu-core";
        sha256 = "d5e36d6626230c1ed3844615650cc6d213f38f23b00b8d98fa83b8b44e9f48f2";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "59ec44810ca57fb975fbf5948488d5f01e7f7db959659b3b76d65a459dd0d09f";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "92e46e1ade873184aceb70145247fe1330f708fd56133a4040987fa1936b258c";
      }
    );

    amdgpu-dkms-headers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms-headers";
        sha256 = "0f18838d45aa5b90659faf54ea97b2f8a799e9b9a9a54f754c3567f612d68888";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.3-2125197.22.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "e910f3cff27abacaf052eaa5be8006fb714657c31655104e45d5dc7ec021f393";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.3.60304-2125197.22.04_all.deb";
        name = "amdgpu-install";
        sha256 = "8c48e63235b40d2ce3bf61d5556a4aeb4c6a20b39ab17f347384979dfef96842";
      }
    );

    amdgpu-lib = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.3.60304-2125197.22.04_amd64.deb";
        name = "amdgpu-lib";
        sha256 = "f5fe953fef149efd5a4399e470daafe5351eb57bfc5b4c344f351e7a13430777";
      }
    );

    amdgpu-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.3.60304-2125197.22.04_amd64.deb";
        name = "amdgpu-lib32";
        sha256 = "e83df2e44abc78c4d8f6460c982bddfe71d3bc5c0d3da984501463b3ec975eac";
      }
    );

    amdgpu-multimedia = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu/amdgpu-multimedia_6.3.60304-2125197.22.04_amd64.deb";
        name = "amdgpu-multimedia";
        sha256 = "a229b21dfadc0705e9cc082fbe90767a3af80c0a949a7eda5ebb217fdd1f06bb";
      }
    );

    hsa-runtime-rocr4wsl-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/hsa-runtime-rocr4wsl-amdgpu_24.30-2127960.22.04_amd64.deb";
        name = "hsa-runtime-rocr4wsl-amdgpu";
        sha256 = "14a7e9b6903b6716fe623feacb10f32cc2be00d6aa088096657ea5095884ab6c";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "e86babdbdd468337f8afada8b293b8f8661ced3bc4a690bdc0aac76d7a1ec760";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60304-2125197.22.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "1a3967df29bfb0cd80a86088023c20dd5c1136a61f88fbb54cd71d1f92d4984e";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "6d4f56ccbeaeab428139ef4e2647e0bf1bfbfe3ed49739c1ae74db1f79c0220d";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "1979c584443ed70cbb6de3cb2a56bf1771aebf30155cef42c94ea6879072316a";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "2bf441625edd9502281af79d569b9d3982c68fe101f0bd125cf20f6dcfd41eb2";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "5a5ed4be0b0660a616918364671105aad69d38a34eb01469a941bc0cfa4b396b";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.123.60304-2125197.22.04_amd64.deb";
        name = "libdrm2-amdgpu";
        sha256 = "6bdcb573de62e3c539ad5e07bdcf66c0385cce809fb5c8e5f1eaba4858efb7c1";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "811ad885c733afecdc3bcd99778e7f7fa6808192f3e763a058d2de2514b1f83d";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "29be6e1e1a4b8d48d3b6ff5950c901ff811a527666f8fdad1b9b8ba64f1a71a1";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "f437d8b6486d5e88164b4a5c06741bfecef9293cae58098317b7f012b90ff2f5";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "3149c5cd20877307c9a0469478c239e00095bd63b8afaa19e3f8446d7218d22a";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libgbm1-amdgpu";
        sha256 = "2a1c21d78a8982bdc6be4de82afe959d055cb528050153c75cee78de89a8f167";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "d8272d1c9331f59d5e48042718397a31130a1657175081716d4bd54d0b0b589e";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "a5e9fd39ff5f2c179b375fa963eec67d15916454019f5fefe36d6a4c4d0bf084";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "46bec72cf239adf21a56adea98d15210307ed18f498dac6f3c76203e3d98a6ef";
      }
    );

    libglapi-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libglapi-amdgpu-mesa";
        sha256 = "d16b7af507f5084b93bfd524dbdc97f3660712bd87047b05ec8d9011af0acbb6";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60304-2125197.22.04_amd64.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "31f1646b6bfcbf6fea1841d278594021a39623a0fe1fdb4d94d35df4444aa177";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva-amdgpu-dev";
        sha256 = "4d555944b0097e60f435c1003f8f091df1a11abeab8cd05f80c01daa0c2a6494";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "9a008d37b89d183ace422b2cd8df477fa05a3c08fff7ef40dbbcfec1be843ca5";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "1288171f45708bf876b05f10f621eeae71a8d0e2dff6a74da863ddee3ad33814";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "bf0d802f7e73cb53331a5f38dbac6c5d1c23a8defc18a9dfad4bfbf71ddf88c0";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "bea05c515ababfb54168192c295795d4a97b5516e27757082eb6be17c20fb1d3";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "libva2-amdgpu";
        sha256 = "91a1c8d1bd5174fa835eeb492ca1e90b759f2e423bb3c5e673786eb4707088eb";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.3-2125197.22.04_amd64.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "a2db299648c19f098e36d54c5a0e5ba3427d12ad76033c73070ad5ab963d3b57";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.3-2125197.22.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "0250830ef36354cf4d857994ff526a492775eb606b4210d0e2ddd86ece4964a5";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.3-2125197.22.04_amd64.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "ae3eb6bc9f6ee78b3d15d815e1346f04e5b55b8a4038474fb905579b743145ff";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "110e9f7317507b2b0ffd25b3b3e5ba8ff20083b155b41876b49812214ec16a60";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "0fa575615b651f1376b40bcf3367e8fda6392232d24d44175d30c05385850d35";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "84fa9eed8072fb6574ba4fc181c71f64c5c5e6952385f600f3b058ea35f3ec16";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "3165ae9b9e81ba5b1950d0576360eb4a2b9b6684128c6f0c3f1ee30d500b90f0";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60304-2125197.22.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "b7c5466c1eba711371aa52ccd874461859d3dfd2b5f5637a7e2d888f873c5f28";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "c8f716d35a85cab5ae3fcc2103909e230b57c5c36bc7e35f48764abe5156b822";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "8bfb0461a73d1bfe0d4d1006d5fa908a00411a1a3c74d9017c99c49d6c0d68f3";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60304-2125197.22.04_amd64.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "ea0077db404fd0e2a3077e42eaee1675408eed7842337384ee4917ee9dad2463";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "e86e1c5cfba1f8f03fa3b8eeeb23af2829c288fa5650e6d05592da562e525dd5";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "16987276810c0966be31c1b3ca60df00c3527229f7b8e67659de3aa769bd7889";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu";
        sha256 = "b617cb4191cf3f3917a23980aa413c22423f56a082be1463a6ac7fff2a20c417";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "59cc36f500631c812da494ec4a53969f52f9f5492c593224800e98a38b600ff9";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "994783b51c09d4a2d4fd4076d493d3fdd54e033036fb27c65daa9cde74898403";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "faa00649cf74a3e260204d21abcdc6afc7efb6f6ac31f0bacbf432684c7dc889";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "b86b9026beaf6d72002fb24c29c7f6a80568470aeb632fd35ac3c772e61416fa";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60304-2125197.22.04_amd64.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "d930d538dacfac985754aa97a3a2d088de2ceb4bf6283a0089a250d39b7a7405";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "fd94219f0cab0bb2b475daf32d29d0f838751dd469c8915166270e05184f2b27";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "23c80c0158a4b5eb4372993ac460aea777d950c455729e071a8e3cba45519412";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "e94a12c63d5103ca0af0c09512f7c3ee42fddfa18ad05e12069aecb4684c10f3";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.3.0.60304-2125197.22.04_amd64.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "9b3365c9caef4d9ad021a30cb8b30b42419b92bbe95b5dbffa07920f677844be";
      }
    );

    umr-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu_0.0-2125197.22.04_amd64.deb";
        name = "umr-amdgpu";
        sha256 = "c9ba9a00e1eca7f60a85cffcb7482f0667a5532c4b68167b70c7d45ee294e79e";
      }
    );

    umr-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu-dev_0.0-2125197.22.04_amd64.deb";
        name = "umr-amdgpu-dev";
        sha256 = "34fbfdced69702523430f8f1c0a808a7f552b3ee079af0dc85598d2d2d8ac089";
      }
    );

    umrlite-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu_0.0-2125197.22.04_amd64.deb";
        name = "umrlite-amdgpu";
        sha256 = "a836fe13ce9a10b2ac4c5d9407c5f25434104c3957e5d2685afa958133b0ad0c";
      }
    );

    umrlite-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu-dev_0.0-2125197.22.04_amd64.deb";
        name = "umrlite-amdgpu-dev";
        sha256 = "cc7c0b4e547dbb376f7d3846c288ebdbe4ea353fc10cf4cc35552236742d351a";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60304-2125197.22.04_amd64.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "089b36331d1ade028d2ce2cbdbd43fc1e21e9913259f098e00b39c15120b51f5";
      }
    );

    vulkan-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_24.30-2125449.22.04_amd64.deb";
        name = "vulkan-amdgpu";
        sha256 = "80264d9e08431b7c9da5faea08735189d57a73a9b6a9fbb4ed2067374b343fed";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.36.60304-2125197.22.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "63a0d6a324bf6ec1fd5f7ab9684b31940d311c57a8b910b2c28719b2099222aa";
      }
    );

    xserver-xorg-amdgpu-video-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60304-2125197.22.04_amd64.deb";
        name = "xserver-xorg-amdgpu-video-amdgpu";
        sha256 = "3b0d121d58ed6ea9da7911f3193f7d5a3e6611e1559a00d6221be10f1dd1269d";
      }
    );

    amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_24.30-2125449.22.04_amd64.deb";
        name = "amdgpu-pro";
        sha256 = "9e3702cf387f4ab5ccb298a987e02d794c6635f854cce32f7ac4fd0a61378a4d";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.30-2125449.22.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "621825e1f30eca14ed0fbbda3d9bd6b7a976b714a29462e3dd156fbfd4288725";
      }
    );

    amdgpu-pro-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_24.30-2125449.22.04_amd64.deb";
        name = "amdgpu-pro-lib32";
        sha256 = "07b5e250ac296a6388e79a962098856207ae32d10817f86d15e0c693412422fc";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.30-2125449.22.04_amd64.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "d14a12ae7bc4b46236c8398957d7dba7c0e0f1b1a154a95264258a63c7d6f422";
      }
    );

    amf-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.36-2125449.22.04_amd64.deb";
        name = "amf-amdgpu-pro";
        sha256 = "9c18bf369b20b2216ba59e5b913de22296d262f7644207b2b7a92179faf9beca";
      }
    );

    libamdenc-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-2125449.22.04_amd64.deb";
        name = "libamdenc-amdgpu-pro";
        sha256 = "22021c6ee8096648812f6a76c56ec2eb3ff5c6034481da660dba348475333ffd";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.30-2125449.22.04_amd64.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "d26af55053a115500cf71c7be40dd4949672fc001c936506abc031890a7d03de";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.30-2125449.22.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "bf1204d287104cb30a8316a26ce57560de6129d75fe65bc1b5b055757e2d3669";
      }
    );

    libgl1-amdgpu-pro-oglp-ext = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_24.30-2125449.22.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-ext";
        sha256 = "9abcd4522facb0b45f5fc3af013cced60be48c1e4909436edffff7ce54afee78";
      }
    );

    libgl1-amdgpu-pro-oglp-gbm = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_24.30-2125449.22.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-gbm";
        sha256 = "dfd883f33b323cffafec331f4f60e6ae625b99d0682cb0926817f3b2aab0e2bb";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.30-2125449.22.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "ecdc83032e5de80678d5c4b1b99266282ec268af54b87007e25747f8f99af988";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.30-2125449.22.04_amd64.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "89f63f1a1f1911bb0cc4f604379ee81889a73ea1b1cd75c58c8ffa6967af86d7";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.30-2125449.22.04_amd64.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "f7fabe430fdcc96d11495b7366e90df17139e9d84a085971b454f4f679debc73";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.30-2125449.22.04_amd64.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "117af2d9b64a5b4971cb5298605309b8c3ac931d9494d2b2cb5b9b226728c701";
      }
    );

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
      libglapi-amdgpu-mesa
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
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.3.60304-2125197.22.04_all.deb";
        name = "amdgpu-core";
        sha256 = "d5e36d6626230c1ed3844615650cc6d213f38f23b00b8d98fa83b8b44e9f48f2";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "59ec44810ca57fb975fbf5948488d5f01e7f7db959659b3b76d65a459dd0d09f";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "92e46e1ade873184aceb70145247fe1330f708fd56133a4040987fa1936b258c";
      }
    );

    amdgpu-dkms-headers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.10.5.60304-2125197.22.04_all.deb";
        name = "amdgpu-dkms-headers";
        sha256 = "0f18838d45aa5b90659faf54ea97b2f8a799e9b9a9a54f754c3567f612d68888";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.3-2125197.22.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "e910f3cff27abacaf052eaa5be8006fb714657c31655104e45d5dc7ec021f393";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.3.60304-2125197.22.04_all.deb";
        name = "amdgpu-install";
        sha256 = "8c48e63235b40d2ce3bf61d5556a4aeb4c6a20b39ab17f347384979dfef96842";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "966f8e008e3d3e876e03ea9aa64fdf84f510c78b879e52c235f388e362217ce4";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60304-2125197.22.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "1a3967df29bfb0cd80a86088023c20dd5c1136a61f88fbb54cd71d1f92d4984e";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "9d12356f583a0c73fd67895367c8b36ac49916f6402cc58ec40db36d06145576";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "8700b9920180bf9148b3513e5e2780b319912f409c5248c0048cf85dbfbd6e44";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "e20d8e9f36a97c7a34163b5eae3e0b1ebc69a9327d068fd1471e8c72c37ca18c";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "6c2eac51322b7ddf646010fab31f3d6b858e7be1133309fd9683f34a19edd110";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.123.60304-2125197.22.04_i386.deb";
        name = "libdrm2-amdgpu";
        sha256 = "96c2c81deb6b21f03c5d4b0075af8ae7f2969b25e4ab6586d5f1b1fba031b9d3";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "74ce0a6cc391aad0b2cfaa92f12a2b3de14f44fed1c81a449d17e54efb6f50e6";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "8f1fa450472eb2fb2d8666780cdc671c1a8f3a0919b8ebe1efaa093a6977378f";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "2784dbffbe026d627caab7152a4a4ede5b59e810ad0b9e3a36a8c92b39ef2729";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "2a4619d241c41baaf66c5dacf93501aa8b45907ccaf32b31dfc092b4cdcef043";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libgbm1-amdgpu";
        sha256 = "c8bbcb135f31d45855aeb1bc083a149ac7b8f8cf61598d07c57982f7fdab3cde";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "d9d2cf89b9a52ee1b6d2bb9a680f388abb69d327b8772244889e23c04b631243";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "323e69413a0c9a8f6e74b80bbd7e29810445c92ad6603cf38c26637dcbf3fdd5";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "21cd79d0441829a093f4cd8f1099017de7245aa438bc30c69d9f59416dbbf04c";
      }
    );

    libglapi-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libglapi-amdgpu-mesa";
        sha256 = "6c5d2009f5a56095d7346d994b86656273c2727660264d80d43c304169555666";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60304-2125197.22.04_i386.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "1037b3ea7b3185be829775d30171d071df39e7282b74b99b44c8a00626dcbef9";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva-amdgpu-dev";
        sha256 = "99f8a98f106aabd23d89ff810f31872021a99d06e3baecb7b361384751c994ce";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "f4304e7304ddac99b051597f554d88ea869b673707eb28344be800f83debf620";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "35158d74cec467d52f0e246fe8c410a728c156679969834179e658ffc52a3a1d";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "c467ae33b27ea2f3101415d34bd34b6a8ab844768cf912c2ed1f0caf03b722d6";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "350ad7bd5e1f75a9b7690fd30d5cbd26b53c44fc8c3c10499e6903f43413e947";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60304-2125197.22.04_i386.deb";
        name = "libva2-amdgpu";
        sha256 = "bac22a20f223d9af4dd7ad11b7051127e2f5206abc102ccdcb90c593cbce0cb1";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.3-2125197.22.04_i386.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "1b5615904dee441e387db69d3758f68e46c87a85eb86a0ec02e2b4f476b27227";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.3-2125197.22.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "0250830ef36354cf4d857994ff526a492775eb606b4210d0e2ddd86ece4964a5";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.3-2125197.22.04_i386.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "356fe45d1a679c76e8fc08f99d07cdd0e698a13e3d042eeb129f1d498ccf4b5b";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "aa5e225ad2087780a5ddcdd081066b113bfe3f0154e1a1d021c88928791c3f24";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "460ff2789b0a6b08ee908f9376dc2f6ec4cf0bddfb1b0a49b8bc541e86158ad8";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "beb01b7e8c63687c1412086a73fb9c12f54a0eb303c484318eb27b91f89051c2";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "360f4023afb5f56a4e5ca6b5bc71892faece3737163ebe4b456b624b890e4cff";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60304-2125197.22.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "b7c5466c1eba711371aa52ccd874461859d3dfd2b5f5637a7e2d888f873c5f28";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "83e17717b3acd557d4c9d6463d66a4f7f9e7f6203102e641ef479e49da6c0050";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "72038aba82fb2db32e89277f59a2e4f5cb5d327ee9dba39722aeafbec4fa7f2f";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60304-2125197.22.04_i386.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "da657c80e06e9581688ed07accaec443c80b2dead6fdd512b6a2a191835fb116";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "f763416d6dbdb2a8721bd7a49b8ce4990aee64c6b1ae2d60f8ea56e2ab4b42d2";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.3.0.60304-2125197.22.04_i386.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "7e518cb241b5b0026b8c1a79576ce57ea103fece6887274fc99ce1ceb7c27835";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu";
        sha256 = "f264825d867f850012a6cd5482715c33ea46af300c4ffa68d3af7b001dc2ec5c";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "bbcfdfdfc71a5482ef7546b214f1c2dc2255cb11f19480eb50d1ea312e80dcda";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "b0c0b8b06b54a1a1178f3b6988b31476febc9ee201658618991942ec0d802bba";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "6d4a5f17e312c3ff4d836b807a37e29f831665262e49200bd2fb54d6e416ce41";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "4e30efba171897d1f0c96d418e82440aba19e51830e61a059d6a6217e021ae9a";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60304-2125197.22.04_i386.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "4422c15decfb7dbe7eb5ad027ffe78117ccc37951a050caea772cfa2e172052f";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.3.0.60304-2125197.22.04_i386.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "34e9980615d87abf26310ebfbdc0ab6efd76cb24c59ee27b3a7f5e77691cf3a3";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_24.3.0.60304-2125197.22.04_i386.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "b9d265fbb5ff49b4b39761cdc62b6008d5477a90479e699a26ec0081dce0b158";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.3.0.60304-2125197.22.04_i386.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "430942ebbb7fae2db335bb5802448ed1537482ba2c3ede6eee5cf0546b9f2345";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.3.0.60304-2125197.22.04_i386.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "d434e4bcc570b77d6d1e861cc33041d32485e088cc13174ea90ddce63e4b6239";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60304-2125197.22.04_i386.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "b137b43397868b330a67f97b95ad5207b8cee843d755da0d46c15ff433408da9";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.36.60304-2125197.22.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "63a0d6a324bf6ec1fd5f7ab9684b31940d311c57a8b910b2c28719b2099222aa";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.30-2125449.22.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "621825e1f30eca14ed0fbbda3d9bd6b7a976b714a29462e3dd156fbfd4288725";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.30-2125449.22.04_i386.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "8ee27a6a825417825e122ddbb43c6b70026aa768e4647eb8eefed0a1f91cce58";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.30-2125449.22.04_i386.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "28e13fbee4e4d6bdf6e1efb3124dba4ce1940050d4c8bb8f481c7107cf32a485";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.30-2125449.22.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "68829112a19a69aa4ff00df2083c20d39a772640f909b23f108a0fd0d4377e8b";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.30-2125449.22.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "2ed5137a2b7e6962690a73a43ec28c91fb197f2410868de7d5b7ee1710290174";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.30-2125449.22.04_i386.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "08ed6eab10a0bc1232464b3f8f991ee6d5250fd4abdece5432c8278398e45de5";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.30-2125449.22.04_i386.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "56ea9e91daf51820561832c4f30fc8eb2c0f91022d9b01de59e7643b325fd85b";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.3.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.30-2125449.22.04_i386.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "0755c952c9e4045203084f14812e92b29f5271515cbb2e7304ca0bf06f08baf7";
      }
    );

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
