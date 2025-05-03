{ fetchurl }:
{
  version = "6.4";
  bit64 = rec {
    amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu/amdgpu_6.4.60400-2147987.24.04_amd64.deb";
        name = "amdgpu";
        sha256 = "f49b10c60a36a4e16aeb84fe294d0871507d22156f81b7e2a12cf2aee2bb70f5";
      }
    );

    amdgpu-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60400-2147987.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "364f4077e710051a25964866cb9411138541f86171239ed4dc84cde7d662a294";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "532eeade51645eeb8313c7976c3f7e322122f45cbd5401333b93c81c616b371e";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "f37759d5ee49b21d2411a8f593384dbcc245a94020343c8217d1dfe661b63e13";
      }
    );

    amdgpu-dkms-headers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms-headers";
        sha256 = "dfbc99ec453d4f57077b70c778095912830e32b4dc6357971e5e6fff8a5910ef";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2147987.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "aec91119329a511eaf53624167cf1611b12ecd91b01d6a1eaacec4239cbf46e2";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60400-2147987.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "d2bb6549b7e216d4cb37bd3349b4972357ad35b8e742791514e9e77539d26268";
      }
    );

    amdgpu-lib = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.4.60400-2147987.24.04_amd64.deb";
        name = "amdgpu-lib";
        sha256 = "a93b7d2abb6a6d79d85491473f994554cb34cb8f946c92a6e93ef928598ae435";
      }
    );

    amdgpu-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.4.60400-2147987.24.04_amd64.deb";
        name = "amdgpu-lib32";
        sha256 = "9cc43944439cfe0b9f85f4bc7d1f6d27eab29f9d56536cf51fcb8177fd4c7472";
      }
    );

    amdgpu-multimedia = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu/amdgpu-multimedia_6.4.60400-2147987.24.04_amd64.deb";
        name = "amdgpu-multimedia";
        sha256 = "830b39246ddad4b7cf1eb28663a0e47c4d2cd42a74bf50eefd43ed636d76d76a";
      }
    );

    hsa-runtime-rocr4wsl-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/hsa-runtime-rocr4wsl-amdgpu_25.10-2149029.24.04_amd64.deb";
        name = "hsa-runtime-rocr4wsl-amdgpu";
        sha256 = "f8f4cf3f1cefd78f499fcc8e8695a0acb55b102459846ae7ef4280dd198a7bcc";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "4a2dac6edbdf389c826b36e64de96fbcd709914183205d41fe048a5cf4a44da0";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60400-2147987.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "64ed89cf20170a84a6271c4ccde8e722a75e758546e43ec85f7ec912bf4e4a68";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "6da35c0701041899a033dc7642160df2ef3397f675ef43b10c0b7ed19a5b5abf";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "3512ec2cd3712064a148b130fa632beebc2dc7b1f527be8d7321ab05b38c3113";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "004821495f31facf9501311bddcdf234985d858ef3c591d3854df90e9c60c1c8";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "460f348c571033751ac308b874e35cb652387e86c1d79da8a95e2ae324353fb3";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60400-2147987.24.04_amd64.deb";
        name = "libdrm2-amdgpu";
        sha256 = "4abeae9eb7dd559d9a6ad4f1bc39ec3ad96f660aa78327d6f7096443408166e7";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "fa0fb80ce1b6ad3722634669e2e8529d76109dc6147b96e616590003c2137ebf";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "d4ecabab7f840c5f9f6bdfcefea81f1b70ec897fd7c64df138c2377a18d23ca6";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "655bc1ef7d8dae0989a494ad362bd821f91809959914959149305a1b554bcd11";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "89028260edab50d722b656c6138785d2f55a695044d852349825cc58f08c7f26";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libgbm1-amdgpu";
        sha256 = "3f3c7c68de981279f0af918dc598c11e273f65309d18b80e01626e056e37243a";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "c2b995123857becb21dee86e185eb723f8db2c34f4c0c03bf079381031775905";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "c6ab6ecf4f8565359ee838eb373cba77f6582e98899de6d514e75806d8ac7b6b";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "9c81dcc145e0225592d566d259c50d1da88fa342185d7c477d22da1441eb2d88";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60400-2147987.24.04_amd64.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "08d2b4712a443531d36196567fa6f912214ac23b583b5cdb9d164e6839b180e4";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva-amdgpu-dev";
        sha256 = "6b30501ac1769e0def0ff8a6534ab7208e2b3c7ab433180dd125f6460d529400";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "176d5e7f66bc3de42cceb9ffa0a8a2e926729744065a95595d878864f01fdc75";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "ad409cc309a2594f935352f48d1d4e03bf4852c2fdbd4cb3373356174c3572c2";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "59d0c9549556db67838feecaa2bfaaf5e4bbc5ce61345a48df25bddd64d2c8ad";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "0c6c2a9fb584fb25c58134ffede29b6d5e98b6a9a567e786458c6226bdb7c796";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "libva2-amdgpu";
        sha256 = "819c0bbe88037897f1d13b14f1da078474291f9a017b84711ed514b2f71e4159";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2147987.24.04_amd64.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "a0358f472b01fae980a6227d1db8cacd2fcd392e018754ec887ba05454d1379d";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2147987.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "382313f879e43aa6bbbd78568beb33a7cd7ed5c273501a9afdca300ef6a1f125";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2147987.24.04_amd64.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "367f5bcedbf41839fd71df445a9ba933df8a1512cde2fad3b1c945c3d86057eb";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "33fe73cd60cbb40f672c24448f024a3bf31bda71c4ba00089ed1a230f6db4e97";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "859791d83123182a5f01b2748e56c06096b58bd96c719c1dc153334343cca30f";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "3ba027b9c1cb4a04a5ada80ecceed3bb29170c08846acb38551d831f7e7567e7";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "3d120319ef52cda7563aa67557167a00323cca490e6d4f163b2624f35b0d6c57";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60400-2147987.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "e7cbf34307d194008ad46828d303acf013f43311233a5e09b947dc3aaedbd6ba";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "e17d16dc2ae62f8979beb1382639fd9704f831945c7f4f9a373254ad3351243b";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "b8e95f43ace882ece0df9606939ffd508bd4d1ccd074c7741f489129189849ae";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60400-2147987.24.04_amd64.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "ae82b5f6c85a6ffcceafbdcfa5c868fb448a8d67379e28ef05de62dd8c084171";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "cb74bdfbf1eb0d9cf4b5598bc6ba6a75b65bd4fc7ef635eec5ff9d4a0df717c5";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "d400c1e967c94fa0bdca56cae77ab37255fcf950b440a6a215343d95131e5119";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu";
        sha256 = "57c85a61dc8cb19693d79de68849c23b96cd38079639dc3386dcd778a8014ef0";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "b8717c691d06b05cf3c3fd664a2c07a8eb6ec761a23cbae7730a567e5b000342";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "40dc69617a3ebda26a1d0145ced00155e01e258b3067167f7b04ac8565b4b54a";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "ddecb905265d1ac714a36eb3e381cca6a9ed31a28e82118824e28ee4a318e4ad";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "5c2d642f438a2ea8c5451d578a58cefb29fbedfff9091528f43a4c9b98b2a9cb";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60400-2147987.24.04_amd64.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "bc0bce428c90460ea72b210892e9b771c6365d8a4a11bb43c4b340b8f7f6309f";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "1f3f1eba44e81948c2fb7294b6956bf0f176ab752f798d8d8e5ad5eeb3e837ed";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "0549a00dcd6736785e0d804f5811d9573d1160e1d787000b11034cdfcac52e9f";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "22234e97eccc20fed3183d89f8654c1a0d76f2545defefc04bd38450ca23d724";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60400-2147987.24.04_amd64.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "c87ecedf1043bce633db9bbda678f03a166466b1705a9b3b8d03a21654c7afd5";
      }
    );

    umr-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu_0.0-2147987.24.04_amd64.deb";
        name = "umr-amdgpu";
        sha256 = "907ef89d5464506f8c0e4962856d861a65c44c3cadaf2cc4f0e4af6d33254e09";
      }
    );

    umr-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/u/umr-amdgpu/umr-amdgpu-dev_0.0-2147987.24.04_amd64.deb";
        name = "umr-amdgpu-dev";
        sha256 = "2a5246434752fc49f4dd31e738b913952b3d63e048ac57061273d87397a53666";
      }
    );

    umrlite-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu_0.0-2147987.24.04_amd64.deb";
        name = "umrlite-amdgpu";
        sha256 = "fc1722f41fde6bac02731a8be702b792541444d657dc4d1b77bc00fb21347339";
      }
    );

    umrlite-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/u/umrlite-amdgpu/umrlite-amdgpu-dev_0.0-2147987.24.04_amd64.deb";
        name = "umrlite-amdgpu-dev";
        sha256 = "19fdb7cd788a764f2da44a1b587c7b9c6eff87f97fe427c73b8b50fcec6aa690";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60400-2147987.24.04_amd64.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "b9416e5d9e1735686223514c74af696a622bca919656c36233a39bc9785dd5ae";
      }
    );

    vulkan-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_25.10-2148022.24.04_amd64.deb";
        name = "vulkan-amdgpu";
        sha256 = "1ad6c1e806c28193679ae7cfac3ecedb4ce7c87097bbeebc05e35e2028eb2ea0";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60400-2147987.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "a3db285af0688037645cc6871d431fc679ff0bfc594705129d501d3f00f8850c";
      }
    );

    xserver-xorg-amdgpu-video-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60400-2147987.24.04_amd64.deb";
        name = "xserver-xorg-amdgpu-video-amdgpu";
        sha256 = "cd6d610ad974d0031e87f29744523356ebb5b0aca02876f7a0e2a84e0bff3d50";
      }
    );

    amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_25.10-2148022.24.04_amd64.deb";
        name = "amdgpu-pro";
        sha256 = "02a22f587bb01feeffce924342db0718ffd65955ed8805a2decbb296f6be87de";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2148022.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "41898ca188fed233771c63ab7df828edc464ae552cf3243e0bae1f3f0f843c89";
      }
    );

    amdgpu-pro-lib32 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_25.10-2148022.24.04_amd64.deb";
        name = "amdgpu-pro-lib32";
        sha256 = "10ff77a4cbe9010be6fc87fec66f65192293cff4b70894ce2f4560fe789ada61";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2148022.24.04_amd64.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "6c8882f0ebbc2e45c9d0860c01e5936abf874bf3f3154de53602231a75a433fd";
      }
    );

    amf-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.37-2148022.24.04_amd64.deb";
        name = "amf-amdgpu-pro";
        sha256 = "0d6dc18a2c2ad36836630a730810dca92e06581a4cbf1beb4a91477542233561";
      }
    );

    libamdenc-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_25.10-2148022.24.04_amd64.deb";
        name = "libamdenc-amdgpu-pro";
        sha256 = "cf65da46739afb72d535caa154d911e435420d6276d6184c528b3eeee8986117";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2148022.24.04_amd64.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "0a07e24977a2820bd84e8eada83e3a8092800477a70e878ebc10c8386d8b8478";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2148022.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "deb0f316f965eb53041e31d9f6d660a18d7d02fe48c5180522ac2e8c53d323e6";
      }
    );

    libgl1-amdgpu-pro-oglp-ext = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_25.10-2148022.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-ext";
        sha256 = "620522ab97a36172c74bd7a9bd95c5c9e797005073ed24838b7a0344c477eb99";
      }
    );

    libgl1-amdgpu-pro-oglp-gbm = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_25.10-2148022.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-gbm";
        sha256 = "5d42c8f52c7d4cd895d20400ee6a4a5ef2e01fb2214ba1ea6e9d71e1d733af3a";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2148022.24.04_amd64.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "844b38f2953c758201414b360882cf965231a3f87808a3a5ab9019bc7f9af405";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2148022.24.04_amd64.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "6e4e6ce05ed806b093f043a7690f1ee3f6b40f716c475f0773fa1a8b7b19bb31";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2148022.24.04_amd64.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "741aacaf1416cb2000e7e2ee4a684775e7438d4b912e3e2c3979597fb7da11ad";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2148022.24.04_amd64.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "e0af09fbd03dab40290b8601005dd8a8f63d6b2fc58e3fa67c40ca099ce84f2d";
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
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.4.60400-2147987.24.04_all.deb";
        name = "amdgpu-core";
        sha256 = "364f4077e710051a25964866cb9411138541f86171239ed4dc84cde7d662a294";
      }
    );

    amdgpu-dkms = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms";
        sha256 = "532eeade51645eeb8313c7976c3f7e322122f45cbd5401333b93c81c616b371e";
      }
    );

    amdgpu-dkms-firmware = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms-firmware";
        sha256 = "f37759d5ee49b21d2411a8f593384dbcc245a94020343c8217d1dfe661b63e13";
      }
    );

    amdgpu-dkms-headers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.12.12.60400-2147987.24.04_all.deb";
        name = "amdgpu-dkms-headers";
        sha256 = "dfbc99ec453d4f57077b70c778095912830e32b4dc6357971e5e6fff8a5910ef";
      }
    );

    amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.4-2147987.24.04_all.deb";
        name = "amdgpu-doc";
        sha256 = "aec91119329a511eaf53624167cf1611b12ecd91b01d6a1eaacec4239cbf46e2";
      }
    );

    amdgpu-install = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.4.60400-2147987.24.04_all.deb";
        name = "amdgpu-install";
        sha256 = "d2bb6549b7e216d4cb37bd3349b4972357ad35b8e742791514e9e77539d26268";
      }
    );

    libdrm-amdgpu-amdgpu1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm-amdgpu-amdgpu1";
        sha256 = "0d54226abc4673b3d22fdd903226062fd3b99b6c9b12d2a3edb2c71b9a1b2153";
      }
    );

    libdrm-amdgpu-common = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60400-2147987.24.04_all.deb";
        name = "libdrm-amdgpu-common";
        sha256 = "64ed89cf20170a84a6271c4ccde8e722a75e758546e43ec85f7ec912bf4e4a68";
      }
    );

    libdrm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm-amdgpu-dev";
        sha256 = "68c940da23684230a8de42a468b6233c120700a2c479407132f55d61afe1e964";
      }
    );

    libdrm-amdgpu-radeon1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm-amdgpu-radeon1";
        sha256 = "974e8a8607a056ec0c475db9d27941ba2622f7c81941b8285bbcad60e781cd63";
      }
    );

    libdrm-amdgpu-static = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-static_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm-amdgpu-static";
        sha256 = "cfe218d8f39897e500fd80e42bcb7178a59f9ee537cc5f04455917d96a81ab05";
      }
    );

    libdrm-amdgpu-utils = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm-amdgpu-utils";
        sha256 = "f8ac44053db479a2f0c2489de80c1f474ce072906303a63652bac0fbf51e9f7e";
      }
    );

    libdrm2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.124.60400-2147987.24.04_i386.deb";
        name = "libdrm2-amdgpu";
        sha256 = "4dca0c4ffad043bd23fa0711e3974041e235723b309990724e02f1062c52dfd5";
      }
    );

    libegl1-amdgpu-mesa = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa";
        sha256 = "c0d44d8aa8babc7df51b5ced87103f2678a30a78ebc5dbbe96bb6f1b0cdaae78";
      }
    );

    libegl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-dev";
        sha256 = "ca1ea65a6ea8fe680dcb67d0de435b2569fc8db3b1f870ea2a549d7c70c9213d";
      }
    );

    libegl1-amdgpu-mesa-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libegl1-amdgpu-mesa-drivers";
        sha256 = "564f0f4c42714e52ebb548f4e71620cd5bc2383dccbae38915bb8111c6a70ee4";
      }
    );

    libgbm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libgbm-amdgpu-dev";
        sha256 = "efcec4bfbf68ef96af4726c0c9ebd222f5df85642068e9dc53de46a0162a23db";
      }
    );

    libgbm1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libgbm1-amdgpu";
        sha256 = "e54e62c48ee128f848176af4032b3ce50871330485590bf976471ab4b6898a51";
      }
    );

    libgl1-amdgpu-mesa-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dev";
        sha256 = "1292e88ce64dcaece8581be91b312386c7888b40d801e5086cb80ec55a318826";
      }
    );

    libgl1-amdgpu-mesa-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-dri";
        sha256 = "6ec1c3a238958b62230d3c11cefbf2c79f78124bfded4d575abc97e925c0eb3e";
      }
    );

    libgl1-amdgpu-mesa-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libgl1-amdgpu-mesa-glx";
        sha256 = "a80941c35d8eb8c90e206b72f43d44e5486885e4145ec79aa17b80e0f1d552dd";
      }
    );

    libllvm19_1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/libllvm19.1-amdgpu_19.1.60400-2147987.24.04_i386.deb";
        name = "libllvm19_1-amdgpu";
        sha256 = "52ba38911b1a25694458b9b82b0bad77aeb2df0cee44d8fbb7dbf44cfb65c93a";
      }
    );

    libva-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva-amdgpu-dev";
        sha256 = "db569e11c59962c3219412871414ed3b52838d6b66a4e852f891a60dcb507814";
      }
    );

    libva-amdgpu-drm2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva-amdgpu-drm2";
        sha256 = "d1b01321a9ccfe64b9324aa26abbad194cd06986009404c30e8fb5583994897a";
      }
    );

    libva-amdgpu-glx2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva-amdgpu-glx2";
        sha256 = "1f751379c6de04d0a1f23c2b835286310c1bd87423be8303f9e2d3218c170c76";
      }
    );

    libva-amdgpu-wayland2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva-amdgpu-wayland2";
        sha256 = "4e59792f32f6a2f7f783c7d095df8b7f02cdd6e0bf0d7e9d409d16f0477b5ed6";
      }
    );

    libva-amdgpu-x11-2 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva-amdgpu-x11-2";
        sha256 = "c2d140810534ffe0243ab835f7c0609a0fd1273a285b3337ba20e83b121c0c99";
      }
    );

    libva2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60400-2147987.24.04_i386.deb";
        name = "libva2-amdgpu";
        sha256 = "772101d649ca2d193c314925c3798b28ab07789d0843788171e6c22ae77c5b0a";
      }
    );

    libvdpau-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_6.4-2147987.24.04_i386.deb";
        name = "libvdpau-amdgpu-dev";
        sha256 = "dc6addc57f021f0b9e6ffed9cb1fde44e4c790b4b4a914129be64c6018216785";
      }
    );

    libvdpau-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-doc_6.4-2147987.24.04_all.deb";
        name = "libvdpau-amdgpu-doc";
        sha256 = "382313f879e43aa6bbbd78568beb33a7cd7ed5c273501a9afdca300ef6a1f125";
      }
    );

    libvdpau1-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_6.4-2147987.24.04_i386.deb";
        name = "libvdpau1-amdgpu";
        sha256 = "b58819da8503bb9a794cd80073374323728ef6f2dd0ae2c651c55c4a3f170d4a";
      }
    );

    libwayland-amdgpu-bin = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-bin";
        sha256 = "7caa130d09cf4231bb4dabccae1b7023b434f3a479dc3e0de232bfa44371b4ca";
      }
    );

    libwayland-amdgpu-client0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-client0";
        sha256 = "a42cb95d6c9f7adf7099b70fe0bc69750e54e2ed7d085faa1b876801ee6fac6c";
      }
    );

    libwayland-amdgpu-cursor0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-cursor0";
        sha256 = "a3916fdd3d278fe39988acab03a56b865e647814c6a63d3d3612c36c63bf3752";
      }
    );

    libwayland-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-dev";
        sha256 = "38eb2a2d6ea18b3a38f2d61a1645a1d2fa9b6213e7d4e65abf763b674650875b";
      }
    );

    libwayland-amdgpu-doc = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.23.0.60400-2147987.24.04_all.deb";
        name = "libwayland-amdgpu-doc";
        sha256 = "e7cbf34307d194008ad46828d303acf013f43311233a5e09b947dc3aaedbd6ba";
      }
    );

    libwayland-amdgpu-egl-backend-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-egl-backend-dev";
        sha256 = "c1f5db5b19bbf063a44ef674170ef027483f28ca18166b26545aa8c614c6051e";
      }
    );

    libwayland-amdgpu-egl1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-egl1";
        sha256 = "2db6f83bcd668e1c26045fe3b303a4b307c95c0091f13cffe98697cbf70e05a3";
      }
    );

    libwayland-amdgpu-server0 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.23.0.60400-2147987.24.04_i386.deb";
        name = "libwayland-amdgpu-server0";
        sha256 = "43dc161cf9054628d809208059d4b4c46d500c9d8d117a3bca6b5a70f91048d2";
      }
    );

    libxatracker-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libxatracker-amdgpu-dev";
        sha256 = "cd8a939a37e77da0ebce3004dbd5683b5206af4305691cd1f74c2c01a1122459";
      }
    );

    libxatracker2-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_25.0.0.60400-2147987.24.04_i386.deb";
        name = "libxatracker2-amdgpu";
        sha256 = "b40befcc33b7f824801f957920a2debe48d4d43183d733cc4f01135f8030e01f";
      }
    );

    llvm-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu";
        sha256 = "b58b9cbaaae00bbe63d4aaff9c10d15debdf5692e8f675395f94032b25b89630";
      }
    );

    llvm-amdgpu-19_1 = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu-19_1";
        sha256 = "64f9fe62088aebd5d3a4997a966d8210d313e779bf78d40a9fdaae854c566712";
      }
    );

    llvm-amdgpu-19_1-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-dev_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-dev";
        sha256 = "11d1a0757df855ccecfc619b8f3765c221f46bd9dcb4c95ce9dfdca8e9441b1f";
      }
    );

    llvm-amdgpu-19_1-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-19.1-runtime_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu-19_1-runtime";
        sha256 = "f0674e415de4f8abb43a728a25b26d65ba833a30c8d6a3cf11208ef5e5570f61";
      }
    );

    llvm-amdgpu-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu-dev";
        sha256 = "211c281c3447dd4194f69d287224cdaf686488f4af31cfdd97411ab469b3475b";
      }
    );

    llvm-amdgpu-runtime = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_19.1.60400-2147987.24.04_i386.deb";
        name = "llvm-amdgpu-runtime";
        sha256 = "a305146ec8b342f921ee3c73a18c8262fc72fbac6d5a509be9dfc2b7ce306a6e";
      }
    );

    mesa-amdgpu-common-dev = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_25.0.0.60400-2147987.24.04_i386.deb";
        name = "mesa-amdgpu-common-dev";
        sha256 = "526d38d65b88f92373cc8d4b58ee6cf6ad935603af7a7965f6a8dd904842621e";
      }
    );

    mesa-amdgpu-libgallium = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-libgallium_25.0.0.60400-2147987.24.04_i386.deb";
        name = "mesa-amdgpu-libgallium";
        sha256 = "cf7c454e18480fdcb99dfc5ac66c0e7805fc99b4c8602ae3ee9ed184fb6e1a5d";
      }
    );

    mesa-amdgpu-va-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_25.0.0.60400-2147987.24.04_i386.deb";
        name = "mesa-amdgpu-va-drivers";
        sha256 = "6098142bba5f2fecb4799506c5536164db8454cbd60e3242aa571b05424c0a42";
      }
    );

    mesa-amdgpu-vdpau-drivers = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_25.0.0.60400-2147987.24.04_i386.deb";
        name = "mesa-amdgpu-vdpau-drivers";
        sha256 = "7182a642f43f973071f54a268d3ad0367453d662aa92fcdbcb09872320268983";
      }
    );

    va-amdgpu-driver-all = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60400-2147987.24.04_i386.deb";
        name = "va-amdgpu-driver-all";
        sha256 = "c54af756c5466158a7ff1394f61610c607982b77d7858c8629ee0d73949ef53b";
      }
    );

    wayland-protocols-amdgpu = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.38.60400-2147987.24.04_all.deb";
        name = "wayland-protocols-amdgpu";
        sha256 = "a3db285af0688037645cc6871d431fc679ff0bfc594705129d501d3f00f8850c";
      }
    );

    amdgpu-pro-core = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_25.10-2148022.24.04_all.deb";
        name = "amdgpu-pro-core";
        sha256 = "41898ca188fed233771c63ab7df828edc464ae552cf3243e0bae1f3f0f843c89";
      }
    );

    amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_25.10-2148022.24.04_i386.deb";
        name = "amdgpu-pro-oglp";
        sha256 = "a890d8cfd781e6ce59f851e2c48e0f945bb6d99759a342ffed0bd6a35ed8ec2f";
      }
    );

    libegl1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_25.10-2148022.24.04_i386.deb";
        name = "libegl1-amdgpu-pro-oglp";
        sha256 = "9452dd6c760aff44816bd9da3ca97a90adcf395d4c98eb293bbb6f3773e6337b";
      }
    );

    libgl1-amdgpu-pro-oglp-dri = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_25.10-2148022.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-dri";
        sha256 = "dcfa6f4dbdbe596f4c9905d58aea7adcff4501b34202d1ff7af4785cfead62b0";
      }
    );

    libgl1-amdgpu-pro-oglp-glx = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_25.10-2148022.24.04_i386.deb";
        name = "libgl1-amdgpu-pro-oglp-glx";
        sha256 = "d7f2e48fe6d0311325f8b9a956b60dc61b5500b32ca1bbbb2df6583d2986d2b4";
      }
    );

    libgles1-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_25.10-2148022.24.04_i386.deb";
        name = "libgles1-amdgpu-pro-oglp";
        sha256 = "d2c214b65b1c2d5f3db5a1cd8d26d9b7096a63e88fc1e653aae5bdd07ac0e716";
      }
    );

    libgles2-amdgpu-pro-oglp = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_25.10-2148022.24.04_i386.deb";
        name = "libgles2-amdgpu-pro-oglp";
        sha256 = "fc948bec102ea88d4f8f49450fdc392c3b0561359f3b473810a7e66fc5698d91";
      }
    );

    vulkan-amdgpu-pro = (
      fetchurl {
        url = "https://repo.radeon.com/amdgpu/6.4/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_25.10-2148022.24.04_i386.deb";
        name = "vulkan-amdgpu-pro";
        sha256 = "ad1a9fa6d76fe5d7046307d360361c4f1262950b23dc9eb0f8cfc0a1c7c7aa96";
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
