{ fetchurl }: {
  version = "5.7.2";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu/amdgpu_5.7.50702-1683306.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "f2a6141ab75c9fb739bb00cd6af7c12820afa25e7e784304a38b528ddeb9833d";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50702-1683306.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "5e6193aee43550b48b30497872e6a4fb68ac814422b5daccec26a5cdacd942f5";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "1759f2c0eba8caba0757a5bbfef7c1cfa9dd018f1f2d286cfdaeac7428d45de1";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "82830144949f7eac7dcb556ce533611a6c975771c94f54bebd2e66d81cdf2cdb";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "61e6e5d22314a5b1c71a49723fb6365c14f3337995cefe5c488d35c43cfe688f";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1683306.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "26d5f607bd7bdb7551854d4d084870a068a1bacd9f7498b876fce6f988ce1173";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50702-1683306.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "33d56584caabfaf16368050701d6d917632d568b231869a45e640c68dfecb8ca";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib_5.7.50702-1683306.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "ad5386696cf621229eee5809c447c1e902b86ac12a3265e380855deac2f071a0";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_5.7.50702-1683306.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "e98266058d4fe9673786e9a460a4ba7de1925127c32e589a8924c34c9b7c21f2";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.50702-1683306.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "b87bb338e484cd04c95d36ba1fba48a19ed25fa372d899419544e5e09f372387";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50702-1683306.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "ecb0846236996a5b328405327693094ebb9ed624720a806eb6cc12d412075233";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50702-1683306.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "6ad79c68cbd0737762e485ecf6a63c2da906d416672d1a62ac867b5910726fcb";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50702-1683306.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "b0e61f1bc766218fb0cc58e353a0da65f67791007f25d3be48afac4498a3f2ab";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50702-1683306.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "fe49e31086816b69cae70c268a79922dc7dafb335102249fe7410e21ad9addd2";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50702-1683306.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "f62e2ae5a62dcdd721833f97672c99bead169820c1b47f465f9b0015708c2a1b";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50702-1683306.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "37fb725a1ee04ca96fbaf034376955e1d389950c5f6c19a870475a1468a776c4";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "b911821d9e87a24ddacde8a5288b2c07ce524d84a83fb695159b9be27ebc4ffe";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "c0b3c134051e31c4e32dc19b37d337cb1bddcfe6c497d2b851e550b8968aaa28";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "bb6e760e013f0835afa7ca8e534678ba5829feb88792253abaf2ea5ad4768a98";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "57df7035201441aeaa916739e7a79e6c6c9083154a2c9aed02407fd188a22bec";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "3ccb9eef0c4bdbd0c8ec90dde79da9f18797321477fb49b1274729513bddb6f7";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "61506032380d027441c4411bc14e76906929ef8e6c18b0d44b7fd901302097e4";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "b062314a3f3131a472740757aef1d644b1fd10147e112acb43451d49b69ce655";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "01de54258380c255478e0faa65ec5ea7c6953a1b010d8bd2b15a9bc0808b88c5";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "88218a426258f8095536ccc786c1dc10db73f00e5f9536051f46b88c1b1db586";
    });

    libllvm16_0_50702-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50702-amdgpu_16.0.50702-1683306.22.04_amd64.deb";
      name = "libllvm16_0_50702-amdgpu";
      sha256 =
        "5f2dc1eeecd541574a3d4c625ee3deb71e64bed62c975a40e4a806d53d0d065b";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "d9e09d067381aba64061d922f7aeeddae8036c7441c65542d5bb326230abd76e";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "f482c5acf5ef2678bdd7047c676dde84daeba57ec65ef059949f9317695b58c9";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "46f3e4a05383bbf313b5929d32d901fe04b3cc7900fd0019fddd978224c078f5";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "7ab8c393c31c00c5464b1f93ab6a530debaf25211d3c04d6e57123ea60cfae3d";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "59c378b853a2d0afc35276be807446f3826ecf5816a9182e760f9f5d120c12c2";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "5d07ddaa67708e55ffc0680b2f3d60756da917c4ea673ec5c225d6eb578789c1";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "b629c90ea4104e60098980cb05a00579c5555231608044481735c7c756dac92c";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "68a31ae6aa24058a2f9256622dfd204c7449eb8c4c466b5a7442a496135d5841";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "3e92ec8f68e65c734518d8a972491c1b359523e41250e4570959a4c59750489b";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "9e7006c89a88c613c8ea85e44cad541269a3b12fc27789586d7a818ef8667e12";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50702-1683306.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "902c459e8d8fe30407a68eb8a96b15a19960e330cd5b6e74835cc071dc5d7bd2";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "ebc81da43fa9bfd6a86af0069f7e4d866dba647c3c13dc9c550db6c862e61784";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "24c47f1e1cb36a5900aa0b636d285c20ee490a0ccf1deeffffa3e2e018a47f04";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50702-1683306.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "4254e82beb28336c9b1ea210b3ebf8e51046a5a45321c6047b592b6c8c3c9777";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "a1d80e8ec9281b201f9ea6e59ccb671fdae8a8cdc021353a870b8a4263c1a57b";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "90f624e7155f81f8698c51139884cecba44d9c6678f36fa12030188a26c5ba61";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "940efd8147fb16d255eaec59d8777c4c5ea379768726aedb4910093ed346e902";
    });

    llvm-amdgpu-16_0_50702 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50702";
      sha256 =
        "9daa024064148a21989d15fdb15502251a8493a2df0d9777c14fee7ab9dc144a";
    });

    llvm-amdgpu-16_0_50702-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702-dev_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50702-dev";
      sha256 =
        "a1576d1d48bafb53e72e314a9e7c4c384a018f7b71a8a0246eaf111f5edd153e";
    });

    llvm-amdgpu-16_0_50702-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702-runtime_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu-16_0_50702-runtime";
      sha256 =
        "d6c14d07a83ac84273d1e530ca2c87536363f1044e113e2d1e861f938e0c6820";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "1dd5b674f5f62a9b46bf9134703ab4cd3c53ed760ef0579df2752f31f0c8210b";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50702-1683306.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "22475d31ce85b61cc42fd1218e18cc8931b552e94985e154d1e311b61e9378a6";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "050be9484208becb02103c5949a253420c0559a8679d596c582fb63370dadca7";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "73d809aa59e9b17cc933b1e25c80007d7d60751182e59b504dd396097036d5aa";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "9cdf801641aeb5826f5e5ee08e4918422c533cf34439416b06ff2bc8b91de46f";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50702-1683306.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "d12a895ac4aafd24051947b7804e9db347af2aecf02330fa92674d99a7699b9a";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_23.30-1684442.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "6fa9f5212f7761677f95ef094a4e875abda06fa7ae6db41aef0d121a4dc65bc1";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_23.30-1684442.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "a891be374b134b9ac73061f7b29aaf8e2b24dfc2a637be91ec7e53315fbf5db3";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.50702-1683306.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "92b83627905ff498e59f14202663258c468c56e7e890fb245aa341a46ba80783";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_23.30-1684442.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "520490db381c291a7286478c319d0fe1fee48e6ff73311aae98b47ac7b20cf85";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50702-1683306.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "efcb8d99ea597d8f094a189ab74aa00cc333ac480efcd4ab51624e7f177e5578";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.50702-1683306.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "143833ce6e0ad85de67271e536037fbd2fc4fbe3d52448650b7dd2f030dbf0e8";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_23.30-1684442.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "baf57728bf6416b4432bfa7312e37ce80fb735628c9d7d1368675544c2f8ff97";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.30-1684442.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "c7321a45ff82bf24e16e2d638d85814015c6e639c32772a67cd8365361dbd516";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_23.30-1684442.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "6e5b382bc47168a997f3d40566832d924362b1d2394d16380ae54c61c1dcbcfa";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.30-1684442.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "418527e4cb8d75305efc70083ab76c46658c8d4f00c8a2229bf9f8dbc60abe1b";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.32-1684442.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "5863cab6b63936094ecc1b0d43d888aaa98813c6cf4128a8df39a224b03bd3b9";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1684442.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "43523b6a28f709afa662b3be1808dd3cd2af7aa30c1442343aa0633cc95da506";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.30-1684442.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "a8cb6a920a1bdc1ccb2ce65a23b11f1a9a9ab680c7d68b0859199c304a097f50";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.30-1684442.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "e4310ae27e2c5a651161bc3cf27f1669394d72418f6d0279ea8467f9ca7a61af";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_23.30-1684442.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "fd271ae923c8cd4ed1a141b761c0b06860e7086d875c42b0e762ccf1b1e1f903";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_23.30-1684442.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "2b3ff7e3cac41f426f6abc571648bba774d9a55b584069c3100b8165c535c13d";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.30-1684442.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "fb8b09a1a94cc5074f94c27d4e5a877fef9a30b35fe4ef817377d0ffc293ae34";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.30-1684442.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "0e116c0a769327d7a34e68242399a15809a62f463e9fd77fc1f53471950e2d33";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.30-1684442.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "969c2a7cee05b3a6df48af264af91ab03510788899bd5a683cbea5c069933505";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.30-1684442.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "53acf9676af6cf80a5e9aec078996c415707985dc95b8ef6218dd5f1efaa5449";
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
      libllvm16_0_50702-amdgpu
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
      llvm-amdgpu-16_0_50702
      llvm-amdgpu-16_0_50702-dev
      llvm-amdgpu-16_0_50702-runtime
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
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_5.7.50702-1683306.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "5e6193aee43550b48b30497872e6a4fb68ac814422b5daccec26a5cdacd942f5";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "1759f2c0eba8caba0757a5bbfef7c1cfa9dd018f1f2d286cfdaeac7428d45de1";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "82830144949f7eac7dcb556ce533611a6c975771c94f54bebd2e66d81cdf2cdb";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.2.4.50702-1683306.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "61e6e5d22314a5b1c71a49723fb6365c14f3337995cefe5c488d35c43cfe688f";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_5.7-1683306.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "26d5f607bd7bdb7551854d4d084870a068a1bacd9f7498b876fce6f988ce1173";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_5.7.50702-1683306.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "33d56584caabfaf16368050701d6d917632d568b231869a45e640c68dfecb8ca";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.115.50702-1683306.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "af6178d99f0284113a42bd67940f7cb955249904b17e65993cc770dc58ca0f41";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.50702-1683306.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "6ad79c68cbd0737762e485ecf6a63c2da906d416672d1a62ac867b5910726fcb";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.115.50702-1683306.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "7706b68f38b893d319e813a47c8c0201f62a253e86afc488fba3d83d471a4cd7";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.115.50702-1683306.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "278e34027ad01ebbb154ef6b9ad55b76cf6d0e658ca0d536352293c829bfac14";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.115.50702-1683306.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "4d48eb7221034ba04683a1b484363f6f59128f336f4e8d9828aa9f97e9d157a2";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.115.50702-1683306.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "82d64bb66637b61f57dd122aa24cd4cca349d90446e462497cf23b9dc24ff33c";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "946ce71327875fcfaabbc9c96cbe0977c8959bd6e651b31e0b0f65e6c880bcc1";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "98ab058114c23af45047e68991405dbfa4dbe91c53be03c2d77352c8af2b3f23";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "e2fd8b8f13840962c88a42243aa6471563909729a84af3a8ad5034c937ee9dce";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "aa3c1fd4bd5714960bd81205b497d436467175f1f2d717f61e83cdd53a93d0a8";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "730b53099094aed0dce86c9c666b27c6816f40f9fc41e6a6c743d536a0ac3375";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "2668dafa03e3f573b060fe024e12200978e8410fc391372953aa54c1257aefb4";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "550ce8f8bac3ecd7b1157ca98707580b2716f839a429e5566958bc2543b6e9e8";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "9bcd8d40d2d9384149d8554816a5de971e126e1dc4611ee79e811b46f8d5887d";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "a92f45a84820360e3fdc85f79b5466ffb76ee9d2554ff8c294548a7015f5b1c1";
    });

    libllvm16_0_50702-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/libllvm16.0.50702-amdgpu_16.0.50702-1683306.22.04_i386.deb";
      name = "libllvm16_0_50702-amdgpu";
      sha256 =
        "d92f0e0d063733128c90a9925c8bba16637da3226dd60e4a3d522d9c736ccb19";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "f669f58cd1fabc8937b4204b4f71a4940de3d992e4cfbb4e74bf401771eb5dd8";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "f726ceb1e862b7063ccf5e261f60a1a874e3ea38bda42635771dbbb94a7f12da";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "06303506116c248b350321fae7f2e06d684bce78497338553734c903390ecc1c";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "87f620da3b4fedb7bf59e6d865b93346b14031f1b1d32eb7acdd4894734de62e";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "df9c79f7f5b4379dc0a3e656d2070f342e5d266808d2badad5682f7c274710f3";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.50702-1683306.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "f2a1bfb9f329a1f844c973f879ac2f0d29abe6cfd1a487675f3697c93b51ce89";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "ceffa10357d92d7a40e56eed4d9a240bf924299064643fcaea131981092e1fc8";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "cf41cb8eb85c0be01cd924391127af1f15adadf19c81a96e2a237425c30b844f";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "0b704917b99c3b0c041aa933bcd2e8d3bbad393425b7f61896e9d4bd1057ce12";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "e3ea145ff1cea4b6189cb7f40e7ff396dd48665b30adde1e667f3d3fa29b2d42";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.50702-1683306.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "902c459e8d8fe30407a68eb8a96b15a19960e330cd5b6e74835cc071dc5d7bd2";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "ae22be8569f12c6f4fd3bd5046b5742504bc96425cb38f3f07b9e5f114baf378";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "ede71eaf79ffda6764a8c896f301c064eb4d9370d91f66a2e32154bc9817f59f";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.50702-1683306.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "13c893ac7a60ecf9f3b42f0cf257eb18a7eae029ada75f8551bf284160952238";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "1e888daf071a43ad87c80a5bd49fd8d2526154664cb43b1c1501b31c71653ba8";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_23.2.0.50702-1683306.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "0c2de7c88ef42da1b487ebe553851a6dee6f0f32ddeaefd15ea5d50a5ef1738f";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "883c5d83867abc7fdf4bffda580231194553e1807fa3582d0bc31dd5e29bef6e";
    });

    llvm-amdgpu-16_0_50702 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50702";
      sha256 =
        "cc3713c994cb0d254b27b98ad4ac456f5c6cf64b0575ebf26801ec824daf0c60";
    });

    llvm-amdgpu-16_0_50702-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702-dev_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50702-dev";
      sha256 =
        "c0a11ea59a77e9c96197f8dab30c771f95b821dbdc5adce364fe3408a21c26aa";
    });

    llvm-amdgpu-16_0_50702-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-16.0.50702-runtime_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu-16_0_50702-runtime";
      sha256 =
        "1d2606dc28fdff92405f8062096eab044e41ffbbb6a0125a30686d20b1b1823a";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "d054baf041588179a61b8f3a027a805d87d5cf5d88931bc28412b2dc58d79166";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_16.0.50702-1683306.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "266ca52b90f8dfbc812e9add29ed042392da219501617a84dea234b577f147b9";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_23.2.0.50702-1683306.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "b95931731c3209c2d10800642ed9c7cc22ccc3b22eb7d4f79b2d79771f7398db";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_23.2.0.50702-1683306.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "9799662ae638737600544de1d0680a2da6e997a1e238782b4e21a0f24e16f406";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_23.2.0.50702-1683306.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "8d77890b711881064a2f4647923eb8bb4e61002908629aeda46747f313cd1640";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_23.2.0.50702-1683306.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "cc7df8afbbf3ff23fd525a2d730ae34f94ff96f860127d8dea7470d54433f228";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.50702-1683306.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "248ae81c1ab82656f7838557f285905d553b0d1128033e0626446bd21a222f56";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.31.50702-1683306.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "efcb8d99ea597d8f094a189ab74aa00cc333ac480efcd4ab51624e7f177e5578";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_23.30-1684442.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "c7321a45ff82bf24e16e2d638d85814015c6e639c32772a67cd8365361dbd516";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_23.30-1684442.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "4ce5fa2187be5ed21a26104b3f4dfe7369643d3da2ae0e76959c660c7a5c64ef";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_23.30-1684442.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "caf766d52aeafaceab76b6d4ebe32719677888258692a7af20acef71eaea4f94";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_23.30-1684442.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "6694c4fb38c8cab90b4a55b35157af1aa02c6786254fdc417a345bd84477eb8d";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_23.30-1684442.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "6736060cf086aa21a2159f27958e073a4a00b13fe568c3a34db4a61b7df12f07";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_23.30-1684442.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "8bf95e404a67c888fa4644909be0b72449ed709829e5a00a2b75cc98f6315afd";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_23.30-1684442.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "931760b2a5f0e38833681143c64fccc279961c1dd74f760712b4669651964a5c";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/5.7.2/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_23.30-1684442.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "713625b9280c3820de6908eedf22b7ebcafa1b824ee65a47a7d8f83eb9ea12fd";
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
      libllvm16_0_50702-amdgpu
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
      llvm-amdgpu-16_0_50702
      llvm-amdgpu-16_0_50702-dev
      llvm-amdgpu-16_0_50702-runtime
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
