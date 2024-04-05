{ fetchurl }: {
  version = "6.0.3";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu/amdgpu_6.0.60003-1739731.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "a73c6149c5b18067dde11c7b475e3a24ef90884193e76762c61afc6ca3042dba";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.0.60003-1739731.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "a49c97c491a19e2295c11b3edd33435f3f61654b59e3f41b0943a7384e565ce4";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "87d6626ff1f7f28d77ccd8c76945c608770eef54148f6ac79e0c984c77b16a09";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "52b29527d32e3fd1616364808b4626002cab21ebdd46da28d64de5410019f6e2";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "3898d7f0bb1aee6f9044b4d30ebef5b9421afacdaa26fdc3fd61c59aa9dd26b0";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.0-1739731.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "4542c3ebf09c9a150f8a90991060593525a98307a18abea2d8fcb0407ad43794";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.0.60003-1739731.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "a7c24a4726dacaea6e1f6563534487ff93a987d981df095943b10093ef788964";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.0.60003-1739731.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "9f93b079a8be7ba74e4840c89bdd8f8874a2764ae0ef57af907649b19b695cac";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.0.60003-1739731.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "c060d65467127f080ee9cda3dbde6b93b53bbdc511185b1cc53fa6fd8c4a5246";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.60003-1739731.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "e018d754d65af409e324925c6b5f8e44c6d55e3e7251722ee708587e1fc4d396";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.116.60003-1739731.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "882f10d28813d7a4121f594d99a68b63b0a7b93285bd3f411e97e55a6d77279a";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60003-1739731.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "44965b2329e6898d4f19288564f7dba6040bfa034334432a6a6c48ebf95adf83";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.116.60003-1739731.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "b0154bb74d3fc47f7da2eb2a7232e404b2e6aee0ec8b2bbd231a17be00ec02c2";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.116.60003-1739731.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "f965ee1a54ea7e3206f02f079d5b0aef2787d0344f06c2f74a663bc18af8bdf1";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.116.60003-1739731.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "04763c74eaf565e407681318a340ea887cc5784752201e1fc0ad166a906e66f8";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.116.60003-1739731.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "cec07befcae547b4b7d94a3e119e2944b5f1952347f3a09ca669d5b1a7239eb2";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "729d52a821b3ca66023fd1061dc7c578323aef30391eba7ca17537cfffd05985";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "ec91235319e0ab8c474a4e027630200b60ff7be7d7b5084dc81e888f4af09ba3";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "e1f21da5c0818e295f75df31c32ae33dbb1864c837f6b1e49707e2edba108aac";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "1e51b69fc7784a013952b76d52d78cf7f4287b9a398dfb81477e18a6e018933b";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "9aa8203ec46ed7c36d38c2047f5f6420470e19247460d0b1c6af774972a39be7";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "37c228e5d77f0722568234ca0fab91876613a8c09cb88a03e5aad41aed00c67d";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "1e8f15e05a1465b46a94c041070feebc58a86125d08e181396cec01a8ce97ebb";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "4c75379e9b66d035cd358a53e7de1d528d81ca30aa5d8bfb9efa85a286410b1e";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "0dc2f1bd6fad88fb8787f0e0ac6c42d69cd185de1b0cc15c8ef0ca2d7f28a6ec";
    });

    libllvm17_0_60003-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0.60003-amdgpu_17.0.60003-1739731.22.04_amd64.deb";
      name = "libllvm17_0_60003-amdgpu";
      sha256 =
        "71bd282b29b09040dfbe4fb62bc7669d21b4a5a47577a0b113071b4cdcb1cd16";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "af4c346cb44efb66193a392bb65d9954ab25f512c5f19eae9f721965490252b5";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "1810ddf4260bd455935d62e9bf4a7b4269f29c7bd6f90fb103a90a50f3da0bb1";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "0f1ec266ff0238cb7c68dffac8dec0b95c03f6929b4d401404fe5d7a001bb6ba";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "14d5a69cebb014eb2537b575b2083e04a113e0625bd59a2f7f8dc594dd1703b5";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "f6288361ba4d5d0a0ad9aa8808a4d691191410ae0acb1e0e81020d9766ebb2bb";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "6ac8beba6b674d2d1341455faff303ee3ab22d93da707ed74ee9e55560f85a95";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "01a8f44761889df7b29b0f90f2c1f848db382ff88168ff45cc591fec3f6a7afd";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "d23c3b6f50f4a146a55be52770c14d09720c97e3dc06a49a32e91169f30e7ce0";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "528006c08655fd8cb901769a147924e983ad960476d330f36d3341545d0eee34";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "703084985ee4f77f68790994e99db1771b9b847781bbe7cfb0882b4c3f63a29b";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60003-1739731.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "629fb809aac4f6c7beb0b624821466a83521f75070ab18c9a1240c8ace17ea72";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "cd18c7c5f98da765cf6b71284d62021ea72c9e25570be0df932e8f74243ba97f";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "81295e79a2cd94cc0d5eb9ea375263744687c635e0cfcd7ffdba99c93d3305e0";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60003-1739731.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "41bf781f6d7456ea50148c8dba6cd5b238d706b50a88ff5e18f330487645de87";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "1184182c50fd35e2f9b0eb7d24f626e3aa2a3a12a0873dc122b7eb65d414c640";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "93d37ba5d00c534f2da975e70b07a21aaac560ddd8e5554dd126a807fcb88f09";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "8952fbed8ac2af6f35029004efd8b7254b1ea5fb67da7b6f7664e7199013e7e8";
    });

    llvm-amdgpu-17_0_60003 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60003";
      sha256 =
        "a588caca346c559541ae42a0406cdd7b34f0c2f4f7cc591062c26f2bcfa89a00";
    });

    llvm-amdgpu-17_0_60003-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003-dev_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60003-dev";
      sha256 =
        "fcd7e1ab5cfef5595645801a123002c0a47a8705c15130d17115b54322380ec9";
    });

    llvm-amdgpu-17_0_60003-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003-runtime_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0_60003-runtime";
      sha256 =
        "609f83b65430d51b38d92681d53e9ba512d11949c02d8e453ff6ab7a11d11b64";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "ce566f461f75d7d4908785ea7e3fde9ec04327a5c54c4fb1bb2181dfc939e86c";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60003-1739731.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "163aabfec98ca02d6f2529ae19821fb967da087defa0af4674d94d52ef883fbc";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "3863f5a79964d75c56e48432d621738dc4b1842314efa5017923460a86260bf1";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "4e843e821583e32ce1e39860183a53dd82094fa070a7c4f91ef26c412dbfdc8f";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "5d259fe3142ccb1b2fa706462efa504d69fb26429c02d38f53ccc1f619c62977";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "af1e8c3df548cad519e2b040a21d5994f398c832600e5fbc8b50b4e4027f5ddc";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "ecc16cf9879ed329e372731e5062a55a9d58c4b4808ce9aabba71c2976a5e363";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.3.0.60003-1739731.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "24a52dcecfa228d1221ffa2c37b15d521c98fdaf7a9eb53d28c210764877cad9";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.40-1741713.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "80b18c4366045014f645c237744d1335877d40df4fec4d4d78253032c9a951e5";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.40-1741713.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "9a6c74ad3736bdc87f4a190fb15a5300e26b1023e09269e5658ec72af8a8a8dc";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60003-1739731.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "b761925174b1f8cb9c824596385d2063306c129f08652789c95274dd5795c182";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.40-1741713.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "6d45b299ed627a276748313dc4b139b2d5f8eaf596a0a9e91326a791b54571d6";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60003-1739731.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "0187b74a4b36c80cbcc743396c5854d834e4abc7fe995986de8f99aa0139811c";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60003-1739731.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "2ef687b7f57d0dca7588a20b1bc61e0c95a4ecff5f9319d87a6b5464c7c91762";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.40-1741713.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "f7937e826665c2253a15fef93544ad7e110b05f1e30226b1a6d35a141e495147";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.40-1741713.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "6b374604193c8494b036c1b01089bcf53af9e59d91d0b0d8c7e00944f68cdbaa";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.40-1741713.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "a98c6f7dd6116e2168f2f1485d5084842ddb5ece811aa923ef9230d4dd6b71ee";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.40-1741713.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "72b0461e3ddaebe3ef8e05b17bf8b53ae46bb78139ac58aee4880acded9d3e0c";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.33-1741713.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "92cecf496059b7ae4658ca6f85fdad11821f000d85760832a414997978ecb2d2";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1741713.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "3258c9963de671be769ef959ac105c4757900ee8cb68d125043a52e5c8da6e20";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.40-1741713.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "8b6de9d866c6ff40296697d6d1bc7635b97e133f9d238807fd50079f0754a505";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.40-1741713.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "7411f60e1e7859977461386f411d0321c7799dbfe4a0160a8b4dc14ea5b0e7b9";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.40-1741713.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "541bb5e14bde7e507f023eeeb8987811e0f736cd1f66c77cebc369df0a56a33f";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.40-1741713.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "f001bf9a6722fc420f90897adbcba626384e4e14201b554055a34192fac93694";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.40-1741713.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "7019408bbacbd9a4de4a44b20ee8c56c5a6b085970b2be3517f6aeb9ebc0a753";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.40-1741713.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "c639080e1e97348f8ece493b5f983177845b013decfd9a651c10062523b6b44e";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.40-1741713.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "b40413b762c424f70e87ed77f120adc5ad8d4652341809fbffc484b9aa839018";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.40-1741713.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "8956de5ab6e2f66dd8b1cc805f6b8b8a74642ac76eedfa73da3a6925a2c284e8";
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
      libllvm17_0_60003-amdgpu
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
      llvm-amdgpu-17_0_60003
      llvm-amdgpu-17_0_60003-dev
      llvm-amdgpu-17_0_60003-runtime
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
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.0.60003-1739731.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "a49c97c491a19e2295c11b3edd33435f3f61654b59e3f41b0943a7384e565ce4";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "87d6626ff1f7f28d77ccd8c76945c608770eef54148f6ac79e0c984c77b16a09";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "52b29527d32e3fd1616364808b4626002cab21ebdd46da28d64de5410019f6e2";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.3.6.60003-1739731.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "3898d7f0bb1aee6f9044b4d30ebef5b9421afacdaa26fdc3fd61c59aa9dd26b0";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.0-1739731.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "4542c3ebf09c9a150f8a90991060593525a98307a18abea2d8fcb0407ad43794";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.0.60003-1739731.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "a7c24a4726dacaea6e1f6563534487ff93a987d981df095943b10093ef788964";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.116.60003-1739731.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "42561e6d9303f8fba8a3906a525cec13e2ca86103ddea0e6bc66f18f15623674";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60003-1739731.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "44965b2329e6898d4f19288564f7dba6040bfa034334432a6a6c48ebf95adf83";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.116.60003-1739731.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "7198f7b434776bd3327f36a36871e3f2165f7cfb4aa8f3d17c078229ea7a0c93";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.116.60003-1739731.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "e8f4ce75ff3cc253ac2c54f8347076ec0a8d215edaa6f3cb440e2b4df18f68dd";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.116.60003-1739731.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "582c7a21b9fd69df1ffd005fea2abed441dd228d04b1c279bc319a80f3d3962d";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.116.60003-1739731.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "2772226be7791c49172e606a8067972ebc968ff267af3ca2fc816da433744827";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "b9583b9f471a32ffd9823ef08e1fbd61446fe0b1c39c5257f4654f6c085edf7b";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "384f6bc0d3c59b0159d717f2952d71c4c5ab4c9d37ea98373816d2b69e27267c";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "c8637786f9253dffe10e58cf0f631750fa244167d4c25983c520e64c569ff6ac";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "27df804f85a631cb22d039b852a61a55a71674b0f4fe3e23ab263413423bb4ba";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "96d200a2cf3659d18fe4647b9df79fb822837d5032f257f638d2a6680b95625f";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "dabc94e4dd9458bc304a590015d0a794d3006da209eba9835ffa1a9d694e5b14";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "9ac8d7069dd62c077a753014e27a76c701cfd2acab309a5f2d92aa668f73be24";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "f734f63a2d21de8c89da785349addf392a7b1178da30ee92eb000f6ea8955a9b";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "57c7c407f24b9924c034ebb828dac017e128f793a64271ce46903174e1928d88";
    });

    libllvm17_0_60003-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0.60003-amdgpu_17.0.60003-1739731.22.04_i386.deb";
      name = "libllvm17_0_60003-amdgpu";
      sha256 =
        "627d98505b11a96f389ea9f7bd8464e94b1e78d92eedfd7f741af479617f0f61";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "023694cd0b8fe62ccf154b14a4edbf894c3037371743008ed445e963cfe1dea6";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "c5e0b99df20da0c4d4fc683fa44e3a5e54377943af56f299e92ca9d342fad8da";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "096f56b0af695f777059f28f991d2fe5f515f5d372c65ba7f7e2574de1f254c4";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "0f9925a5197612fc8f8d7cb342055f89e513956e8f8fecf5df5c9e09cab5b724";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "80a1b99b75bb3d44b6cc76fc7e28ab2f7a49ab8902cf176bed30af6c6a19a82d";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60003-1739731.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "dbb9844ef4c0a8994ada0ed4d6018a79fee3b5ab51b0d125e4b1e97037d8799a";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "c7d001c40a07304d8fc72644d863f91747fe78b649cc6b1f0470cdc51ce50f8e";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "681c1d610eea67690efcb2e6a78ee3824e965ef8701ccb04b874d8ee2dab91fa";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "5c59ee440c136ac11376c52f94d5c85a75a3753a9f0dd560501d9480f4a6b98c";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "71281fddd971e01ffa557ff408e7b77a98bc19ff270f3be928ba11de9209b490";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60003-1739731.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "629fb809aac4f6c7beb0b624821466a83521f75070ab18c9a1240c8ace17ea72";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "ec7ae3901ae1bfdc1c3855fb575ddf2824744007e094935b487e67aa4cb449d7";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "0db9f14e4f4278617e389c8d515ef10f9638344e26b749d4dc7ff3c5f0e54ba0";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60003-1739731.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "17da4d8b3e36a66ac740eed0d2b4db4f6c67d0265ac7d7356ce3bc0473152b83";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "f26feec589edcb57b6cf3803c501013f6144add5bbd7b3e39bcf3263d956a8c4";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.3.0.60003-1739731.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "90bef60d955ae096a33be72be88ec9897c8a682e70516c9fb9e549be7df80784";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "ea2841df15f0e730066facd1e1d88d833095cbf33cd21096a4e99732e9361ebc";
    });

    llvm-amdgpu-17_0_60003 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60003";
      sha256 =
        "0b0dd2d3331ba7c0a432e2e4be4330f588ffc27500ebd71bf26fc77af4a84e06";
    });

    llvm-amdgpu-17_0_60003-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003-dev_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60003-dev";
      sha256 =
        "0eaea8eaf834af4581cb3d7b7d2a49844381778e0c13b7acffc1720368743066";
    });

    llvm-amdgpu-17_0_60003-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0.60003-runtime_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu-17_0_60003-runtime";
      sha256 =
        "89b274b355422f009848ef97aaaa812e9e2595a1edae1d179d409b8d59ad2be1";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "2008b08115fcfb6ee5d310053edf15476943fa79d92034dd79f71e69fc2be072";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60003-1739731.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "fe387b651d10e3ea0ba1b5b0e496237446dcc172cebfe293ab2464165ee8f7d4";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "ba2465a57e91fe92d06be201db8f5a0a6a2124f1464f4b905e81240048fca5e2";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "e5a801f8f06500c541161fa0cbddc5f209a10361baa46defd7a42958a1cfcf14";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "9c1c5b0d67d1b540cdd6091d117bfdf353a60f5a4b4e43702a736b52bf91180e";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "0b1a2a2dcc42b4a095b053b88234ea4c658853dbe24f212d4a6e5731a08956aa";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "8e9826ff71fd00f168754714d17730cd4ff64d94156b9759e14fd60a62526144";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.3.0.60003-1739731.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "ea4df13bd668c41d6e14c9c2eb15c061da47d6c418026fcbe6d1b6449a4d80f0";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60003-1739731.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "c8ef95cf56707bf779cb0711c856b1f82a75926f29ca56900e029b8dc7772105";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60003-1739731.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "0187b74a4b36c80cbcc743396c5854d834e4abc7fe995986de8f99aa0139811c";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.40-1741713.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "6b374604193c8494b036c1b01089bcf53af9e59d91d0b0d8c7e00944f68cdbaa";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.40-1741713.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "888bfb6d8dfa8ae0a166717d2c734d4562cddf6464ccc395028abb15ec3c216a";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.40-1741713.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "8aef213cad78eace33393dddd7b8abcc3ccdad8ccd7e81f9788d7f331aa47f26";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.40-1741713.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "a02e63dc2f1c8d21c37f108ebc496c84bfbe34a6d6ab47723a2484f677c977e8";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.40-1741713.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "5c4e4a5d54e654e3a443821ac4e40e05fab000309cf6924858da34332646511f";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.40-1741713.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "27aa6e424589bc7698489fa293802fc17345a6fa5e698123d2763188f6b47920";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.40-1741713.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "1692c5f9b8ce86d89789febb4139ebc746596cbd79cc95535bfbb6f38f9458a7";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.0.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.40-1741713.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "4b23681d370a5dc8bf5d2a029a8e5ea074468dbbe569f60b529a7a4ab9250ccc";
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
      libllvm17_0_60003-amdgpu
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
      llvm-amdgpu-17_0_60003
      llvm-amdgpu-17_0_60003-dev
      llvm-amdgpu-17_0_60003-runtime
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
