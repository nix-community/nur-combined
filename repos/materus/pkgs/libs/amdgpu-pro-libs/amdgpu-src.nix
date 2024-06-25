{ fetchurl }: {
  version = "6.1.3";
  bit64 = rec {
    amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu/amdgpu_6.1.60103-1787201.22.04_amd64.deb";
      name = "amdgpu";
      sha256 =
        "d4c2bb87adedb79b644ae5e780b5204b60a0963f217b54e1f542a56505f80153";
    });

    amdgpu-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.1.60103-1787201.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "c0d72f818369e10011de262848f85940d335374c4fc9963db124ae2668e05e53";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "7e6c5fcd359239a4e8cb06c0f713743f8d4ae64e42edd9107d655cdd57f57e97";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "f17139a1b311300f9550af8157160bbda62f8287c6c7f9a9874e0468a8fd41fb";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "e0d6a1f83b33dcdf22c4043d22302f5d21424d86849c3c99157541a13fc4850d";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.1-1787201.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "98507215a0de2e2d2f457f8a3da27b8a46b52e18127a91d72a912ccf7bf78085";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.1.60103-1787201.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "a50c1d940d111647732174d92076bf7d7ded66020e4b2fcbe8f191e6bdfa0def";
    });

    amdgpu-lib = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib_6.1.60103-1787201.22.04_amd64.deb";
      name = "amdgpu-lib";
      sha256 =
        "0d7c8ac787ad6360074923165f13f0220e08bcd161d0d6e92351a6901b56cad4";
    });

    amdgpu-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu/amdgpu-lib32_6.1.60103-1787201.22.04_amd64.deb";
      name = "amdgpu-lib32";
      sha256 =
        "548da04618de183e30890d83f2819d392e54f1aec3829eeea58670bfce81084b";
    });

    gst-omx-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/g/gst-omx-amdgpu/gst-omx-amdgpu_1.0.0.1.60103-1787201.22.04_amd64.deb";
      name = "gst-omx-amdgpu";
      sha256 =
        "cdc216c6eff818a0ea8784dc8077632ad5b8730f8f90318c9616a397f507ab05";
    });

    hsa-runtime-rocr4wsl-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/hsa-runtime-rocr4wsl-amdgpu_1.13.0-1789577.22.04_amd64.deb";
      name = "hsa-runtime-rocr4wsl-amdgpu";
      sha256 =
        "dd69fb2407f03509937bf0c611c736e853d5a9da849ae2052706cc0f97ca009d";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.120.60103-1787201.22.04_amd64.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "22ce9c8d464fab9a843a7009bc2ebae7eff79aa7775546e16351e530310b04b2";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60103-1787201.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "e46f26302f56abb11f7cd9681861cc60f5bf9cc552d3bb351115c576b5513c87";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.120.60103-1787201.22.04_amd64.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "a4526f6a5fafbfcd9b5125e1bc6a5d7e2b5fefe74cbb07699190c6fac0fa03d9";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.120.60103-1787201.22.04_amd64.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "5a1b2fb735b3c7bef385c3b8b1945b6d5f8e9f5b692bf4fc573d490d9cc35b76";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.120.60103-1787201.22.04_amd64.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "3eba46ae7d65e4ed65a8621049bc39d8fb5f4475ede46629f99cd8c14c6419ee";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.120.60103-1787201.22.04_amd64.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "1cdcd02ac7a53258396599c5fb3e687cf8cc19357d1730ce9fef19be96e9aeb1";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "e825e40c51ceac2d25921e6b047df976c6b7c9bcb41acf4d364200495b4295c7";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "46b3310204b7a94f9f46747b87abe89c68718418ea8cf20adeba7682bdf216a1";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "0f35b2d9beb1b4d8abd054fc7b255531887396478eb37bef9d441e65f6078770";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "208cb6dc0022929c68bc7c9429d4e27b2d790aef3ade3d5b920d55b3e52da95f";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "9fdcd01e745899414a4b075c2a8f5e44cd76b3f0a94bce028df57ad4a24da45c";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "8dc9b646575b80ac434acc4352eca3f2840ae34b191a8fc80255aa3ce8a8d01a";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "22f09303f186acf2eba7b1ab117814cfec9497c1bf6202349c259e14f8ed63bb";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "2f796be8691a51f6ad0b00112f5629e1a02e8b69242f7e7fe9d2740b9719856e";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "8e7c009ede280a4cbf57482a05a423d28c4df5bae0e83a9187a722cea2dc79c4";
    });

    libllvm17_0-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0-amdgpu_17.0.60103-1787201.22.04_amd64.deb";
      name = "libllvm17_0-amdgpu";
      sha256 =
        "a9ac814277fc0b24876aab8c970cc42e9ee733024b1fecfb313036b23ef90a8a";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "4d1a7a06899b246bf6b3fa2efa0eed83b1a76d8c42c9f8ad9ecadb651faf39bd";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "1c84fe489b1745bfc1c3302c42f96d93c46c126f06bf7afb00b7678e78cb2dd3";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "c419e2edc7a89ccd3c4523dabe386b0d82250915763d14feaac8df7cbb681e8f";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "dc15da8f552f108c520a3762c16bb3316cd1edc484e85ba3ffd85ab3c344d6fb";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "f603bdf9c186ff80158ca919e876c9ab235e2c05c206e66a647daa2a80307918";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "libva2-amdgpu";
      sha256 =
        "4c787edbb7971859d81d0b7421560344679e71c052b6ab4aba45949cdc2785fc";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "bd0c2e2f2d737c1c02351baf34052ee91eab937d5204cf5dc9ab9c8f91b2793d";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "9ef8045bcde35a77acfc813d9ab4704a202766fa441085737899f9725128b3f4";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "b957425380f0b06fbb37ea547a2f66ea23b5da375316ceca39b8df60333be571";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "2e98bcd92b5a6c2776f5fe1e76bdc85fd8a5f12978abb63e536c544c33091798";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60103-1787201.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "eb131fbb3bf99899e14cb762df0d4d1e8f344b8e92d063e5bc2105d5640d5fa6";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "5d83f450aee20a33233508aaf9959899625b9c48b132c0b92969d2e7449b7520";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "e381482fa9926f6fc6af60811612c13c02bbf4dc6c7b55123b0aba3521fd00eb";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60103-1787201.22.04_amd64.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "f669367a6713dd1ee52c33c751ad5c4fb19fb523591d58ff2924fbd6059c5b2a";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "68fc5da1abd4d815db5445c40d03fbdbb1caff85e4098b9bb17c5e319282bf95";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "39cd4c26b919dfd1652be00b3bac09d0969f708f78f00d6a8104f9c7eae03176";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu";
      sha256 =
        "e21d63d418863402db2b9de57494aaf11f978220884ffa7333f9ff6fbb852026";
    });

    llvm-amdgpu-17_0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0";
      sha256 =
        "abc7c74435334b021deaaff89695d000e7555f1cc486865bcc0d2178aa994f36";
    });

    llvm-amdgpu-17_0-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0-dev_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0-dev";
      sha256 =
        "08075b9569a8808e1df732af9649f2c09df98154e43ad1d324079e62204b5f44";
    });

    llvm-amdgpu-17_0-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0-runtime_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu-17_0-runtime";
      sha256 =
        "e1e7d0fe9fbdcf4376c55c2432831b7394711bdc47fb5ea1232932c399430e32";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "2cc6538852eb998236464ce76826b915187cb2e1af5e762375317f2075694824";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60103-1787201.22.04_amd64.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "5b6f50c22a7fa4736a6618932233c22be4fec76b75c53c067e6fe6037787ef99";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "fd272a6416d973d08edb59a5ef516d6cc81f50f01b1b9adde1adc7db5457b3db";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "906f6a77ac0bb465367999cd31537cb9ba125dcbb700c2d9c8d82b52dab85cf2";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "bbdc361e45c48194670b03226a9c9905eeb38d83a450a498e8109c8440dc7b81";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "91ebf9f20c99c0e302b920889393bfd2ec214e8072d3c3ee8b1903b28bfac7dc";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "fbbafed93510f056f7e2835883014b0bd1e45bb529c8765a5ec11c4358706883";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.1.0.60103-1787201.22.04_amd64.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "0c32e748ac8d7422ccaa4ed360edafcd37383668633c88a42fe9bc2a68dc3822";
    });

    rocminfo4wsl-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/h/hsa-runtime-rocr4wsl-amdgpu/rocminfo4wsl-amdgpu_1.13.0-1789577.22.04_amd64.deb";
      name = "rocminfo4wsl-amdgpu";
      sha256 =
        "ad9677d5fcf3599d353304bb6fbbc0aac566df0dac773faf0c2c00d6f40c34b7";
    });

    smi-lib-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu_24.10-1787253.22.04_amd64.deb";
      name = "smi-lib-amdgpu";
      sha256 =
        "a89975800c0fc66dfd9a05a413a78b0f50ee67a6dc727f81f004dd438a8d6628";
    });

    smi-lib-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/s/smi-lib-amdgpu/smi-lib-amdgpu-dev_24.10-1787253.22.04_amd64.deb";
      name = "smi-lib-amdgpu-dev";
      sha256 =
        "a9652f011abedf565fb1aeacdcf1b80cb7d27423aef8f4bd968e36a342844955";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60103-1787201.22.04_amd64.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "65491f973495a3818ed0a8744672ce8e3b16a725e1acf02d0feefb006f5f72be";
    });

    vulkan-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/v/vulkan-amdgpu/vulkan-amdgpu_24.10-1787253.22.04_amd64.deb";
      name = "vulkan-amdgpu";
      sha256 =
        "e8db1346b108712d1b91d2f7fe9f87e82b4a27cb722a54082c6cbc59be48e62d";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60103-1787201.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "83c8d72ccbb6f2e0c60b89fb1017ef7a7c237fd340ffee8d4949c74ed94111a5";
    });

    xserver-xorg-amdgpu-video-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/x/xserver-xorg-amdgpu-video-amdgpu/xserver-xorg-amdgpu-video-amdgpu_22.0.0.60103-1787201.22.04_amd64.deb";
      name = "xserver-xorg-amdgpu-video-amdgpu";
      sha256 =
        "e2f5489eace986b6ff3b9f5ddfb95d2b5b288b6f8e68f35c8de93418ae33c126";
    });

    amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro_24.10-1787253.22.04_amd64.deb";
      name = "amdgpu-pro";
      sha256 =
        "1361454a37b613e314e240a405edec0a257c5f7aa4abdeacde6d0bc08ad4714b";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.10-1787253.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "08c50c9e28e558691acd9730be907a2510b47e9d0e8bbfe46ce02bc4a4a56f2d";
    });

    amdgpu-pro-lib32 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/a/amdgpu-pro/amdgpu-pro-lib32_24.10-1787253.22.04_amd64.deb";
      name = "amdgpu-pro-lib32";
      sha256 =
        "7f106eea6e2dd05d9f928c54a39666ce049e2fe753d782666c91247610623a18";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.10-1787253.22.04_amd64.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "4c9c86e0cc2b4b02c7290b8c394b86c1bab5a39a8e630d16fa3b757c012182dc";
    });

    amf-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_1.4.34-1787253.22.04_amd64.deb";
      name = "amf-amdgpu-pro";
      sha256 =
        "e6c308d24b6a4034eee7138a3fd4fdbe3692207422cc5d701e1a897159d8e347";
    });

    libamdenc-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_1.0-1787253.22.04_amd64.deb";
      name = "libamdenc-amdgpu-pro";
      sha256 =
        "45291643783efae295ae4e49f51f1603aa8bd1ff81db3f3f9a57e543f71065c8";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.10-1787253.22.04_amd64.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "7e3619650a25acc50b8d767769e41ee01c6bd95d443a9d3c425494e43e8159fb";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.10-1787253.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "96f4cab0a1f41ce48494c241fd3f5f688a2dd7ac1fe73a0314a2bc69b80b50bb";
    });

    libgl1-amdgpu-pro-oglp-ext = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_24.10-1787253.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-ext";
      sha256 =
        "89307f78bf12f562274026790c0be8aff87116cce92f1130820345f46fd687ed";
    });

    libgl1-amdgpu-pro-oglp-gbm = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_24.10-1787253.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-gbm";
      sha256 =
        "7863304a9a1238275e8fd3e39ff44c836e072898b583e6c56fda6310453ff174";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.10-1787253.22.04_amd64.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "32f29d6f08101edcbb1d5552c7917bc30e4265dba5a1af7f972306fab735b613";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.10-1787253.22.04_amd64.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "0fb8081d1d223d9e6395662f4477ce0a9c4c87f9bb585ea8dddc18fa78197a07";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.10-1787253.22.04_amd64.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "c069add0f178944376468ae6fa15e26bb39d0b56d192b8686e3dd9d8c00c7475";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.10-1787253.22.04_amd64.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "c5a619537aebfebad77bfc55a1ba2fc451c56de8407e54f937250d5639256e5a";
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
      hsa-runtime-rocr4wsl-amdgpu
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
      libllvm17_0-amdgpu
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
      llvm-amdgpu-17_0
      llvm-amdgpu-17_0-dev
      llvm-amdgpu-17_0-runtime
      llvm-amdgpu-dev
      llvm-amdgpu-runtime
      mesa-amdgpu-common-dev
      mesa-amdgpu-multimedia
      mesa-amdgpu-multimedia-devel
      mesa-amdgpu-omx-drivers
      mesa-amdgpu-va-drivers
      mesa-amdgpu-vdpau-drivers
      rocminfo4wsl-amdgpu
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
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-core/amdgpu-core_6.1.60103-1787201.22.04_all.deb";
      name = "amdgpu-core";
      sha256 =
        "c0d72f818369e10011de262848f85940d335374c4fc9963db124ae2668e05e53";
    });

    amdgpu-dkms = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms";
      sha256 =
        "7e6c5fcd359239a4e8cb06c0f713743f8d4ae64e42edd9107d655cdd57f57e97";
    });

    amdgpu-dkms-firmware = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms-firmware";
      sha256 =
        "f17139a1b311300f9550af8157160bbda62f8287c6c7f9a9874e0468a8fd41fb";
    });

    amdgpu-dkms-headers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-headers_6.7.0.60103-1787201.22.04_all.deb";
      name = "amdgpu-dkms-headers";
      sha256 =
        "e0d6a1f83b33dcdf22c4043d22302f5d21424d86849c3c99157541a13fc4850d";
    });

    amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-doc/amdgpu-doc_6.1-1787201.22.04_all.deb";
      name = "amdgpu-doc";
      sha256 =
        "98507215a0de2e2d2f457f8a3da27b8a46b52e18127a91d72a912ccf7bf78085";
    });

    amdgpu-install = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/a/amdgpu-install/amdgpu-install_6.1.60103-1787201.22.04_all.deb";
      name = "amdgpu-install";
      sha256 =
        "a50c1d940d111647732174d92076bf7d7ded66020e4b2fcbe8f191e6bdfa0def";
    });

    libdrm-amdgpu-amdgpu1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-amdgpu1_2.4.120.60103-1787201.22.04_i386.deb";
      name = "libdrm-amdgpu-amdgpu1";
      sha256 =
        "313e2791b4ce66c09d2c0295df305bac6f5e48f53fcc4d387cfa8b6a9bf67ff1";
    });

    libdrm-amdgpu-common = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu-common/libdrm-amdgpu-common_1.0.0.60103-1787201.22.04_all.deb";
      name = "libdrm-amdgpu-common";
      sha256 =
        "e46f26302f56abb11f7cd9681861cc60f5bf9cc552d3bb351115c576b5513c87";
    });

    libdrm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-dev_2.4.120.60103-1787201.22.04_i386.deb";
      name = "libdrm-amdgpu-dev";
      sha256 =
        "17ba288adf2b43d0598c4fa6166618e655d8d19a75a3e2d66afadc680309036f";
    });

    libdrm-amdgpu-radeon1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-radeon1_2.4.120.60103-1787201.22.04_i386.deb";
      name = "libdrm-amdgpu-radeon1";
      sha256 =
        "fde39c7b3458e8216f28f2a47f047b26c5598f7fc1e3e010739b7ff50438fbf3";
    });

    libdrm-amdgpu-utils = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm-amdgpu-utils_2.4.120.60103-1787201.22.04_i386.deb";
      name = "libdrm-amdgpu-utils";
      sha256 =
        "df71c4ef43e6e8978c81ee32c5264d43c3d1e1b77ca640b65dd95533a26be28a";
    });

    libdrm2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libd/libdrm-amdgpu/libdrm2-amdgpu_2.4.120.60103-1787201.22.04_i386.deb";
      name = "libdrm2-amdgpu";
      sha256 =
        "6074147aee18757d7c8f7045971f7d3913ab5c47f3e9a39a00c8148d63c0e872";
    });

    libegl1-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa";
      sha256 =
        "68bcc3a02effc83855770a090b3207cdc0d888b87fc43bd5ef506375a3624293";
    });

    libegl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-dev_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-dev";
      sha256 =
        "14821676da826919915da4fa2b2f0dda1fa1cb588aa582cab5f8d4871b5adf45";
    });

    libegl1-amdgpu-mesa-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libegl1-amdgpu-mesa-drivers_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libegl1-amdgpu-mesa-drivers";
      sha256 =
        "5f0850ebf7af604c52926bc473f687cc51f52bc9ab62c302d6ed15d3593aab78";
    });

    libgbm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm-amdgpu-dev_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libgbm-amdgpu-dev";
      sha256 =
        "08c2621b028c6f83d5a1fa4c4b3ddac98baef786d1b343039430db0105a8ebdf";
    });

    libgbm1-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgbm1-amdgpu_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libgbm1-amdgpu";
      sha256 =
        "054a0cbea10715794079883dec7dccc79a3542005e6181c7860bfaeec88f047e";
    });

    libgl1-amdgpu-mesa-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dev_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dev";
      sha256 =
        "7a50fcfbd676405e49827e249d871cb4f5e395475378176e680d772f634e2cef";
    });

    libgl1-amdgpu-mesa-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-dri_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-dri";
      sha256 =
        "6d93372da1c22d892a58eeb07754da2020734e0c9e82830ca192c5e6fc886744";
    });

    libgl1-amdgpu-mesa-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libgl1-amdgpu-mesa-glx_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libgl1-amdgpu-mesa-glx";
      sha256 =
        "08bffe83cab215c1aaf260247dadabcb73013bdcf4294ef979563ce99c4d875e";
    });

    libglapi-amdgpu-mesa = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libglapi-amdgpu-mesa_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libglapi-amdgpu-mesa";
      sha256 =
        "3654c67b000ed1a5979d542993134ed70caac75fb7750f64591ef99a98a8ed68";
    });

    libllvm17_0-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/libllvm17.0-amdgpu_17.0.60103-1787201.22.04_i386.deb";
      name = "libllvm17_0-amdgpu";
      sha256 =
        "81d4b65f72d25fb8a3cdd36a2ce84ebd47855d0d4356abd6a3cc3d347b49af97";
    });

    libva-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva-amdgpu-dev";
      sha256 =
        "4d902b07194a35c632c163ac96ffed8edadc1bea4f0e71f5515cbbfdc54d4985";
    });

    libva-amdgpu-drm2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva-amdgpu-drm2";
      sha256 =
        "d95412b29337b515684fe9e4d2a8a7ede2cf43fa374bd6465e06c854dfe739ed";
    });

    libva-amdgpu-glx2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva-amdgpu-glx2";
      sha256 =
        "6b516b81a90655de37a6b4e36e7360f449322452cf9e47aa5d8f2c849efb931a";
    });

    libva-amdgpu-wayland2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva-amdgpu-wayland2";
      sha256 =
        "9566cd81dd55e8d0f447ee125e9eeecf4fb483dd5954a89c55f746605358f3d2";
    });

    libva-amdgpu-x11-2 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva-amdgpu-x11-2";
      sha256 =
        "d70e1e446488d2637fae5f0010cc13391bc1bc325288585670d4af3cad575be5";
    });

    libva2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.60103-1787201.22.04_i386.deb";
      name = "libva2-amdgpu";
      sha256 =
        "1cf62f5c49ec86fad6eaf6deaf8b32c2b103bf86a1ac32d2e294016675998355";
    });

    libwayland-amdgpu-bin = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-bin_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-bin";
      sha256 =
        "e35739e44b8fd264b1cfbb8da2433df337815537396e6dedd258e9bfd8a2c375";
    });

    libwayland-amdgpu-client0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-client0_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-client0";
      sha256 =
        "b56d07cfe41bec1b7b0664be22744461442c61d31311fdce496d0f7ca8792a58";
    });

    libwayland-amdgpu-cursor0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-cursor0_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-cursor0";
      sha256 =
        "eef48e0db19390047d1493c6594b37eb4c7dafd69cd6f034a7324fb60370f697";
    });

    libwayland-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-dev_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-dev";
      sha256 =
        "4d9b0272971960c29d04b90a9f5eabbe84fdda3fcea31a3a915cc7a6a575800c";
    });

    libwayland-amdgpu-doc = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-doc_1.22.0.60103-1787201.22.04_all.deb";
      name = "libwayland-amdgpu-doc";
      sha256 =
        "eb131fbb3bf99899e14cb762df0d4d1e8f344b8e92d063e5bc2105d5640d5fa6";
    });

    libwayland-amdgpu-egl-backend-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl-backend-dev_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-egl-backend-dev";
      sha256 =
        "b5a87bc11e3702c7ac5d2979025fa8fb42113b3334fc6252f07ef99271241db7";
    });

    libwayland-amdgpu-egl1 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-egl1_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-egl1";
      sha256 =
        "b8f168f7e3d971de63dbc3fd43fd9d099b6a49ff43343a8b2fcd80f2200daf78";
    });

    libwayland-amdgpu-server0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-amdgpu/libwayland-amdgpu-server0_1.22.0.60103-1787201.22.04_i386.deb";
      name = "libwayland-amdgpu-server0";
      sha256 =
        "447bebc9d035fe2f4e12d98272bf3a65861afc01cbeea4bbb7341be9b0f7b978";
    });

    libxatracker-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker-amdgpu-dev_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libxatracker-amdgpu-dev";
      sha256 =
        "860c0d6852916192ef73054ec49668eb18329d05b49ce5e9152978bdb8e93068";
    });

    libxatracker2-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/libxatracker2-amdgpu_24.1.0.60103-1787201.22.04_i386.deb";
      name = "libxatracker2-amdgpu";
      sha256 =
        "685fce1536c7967618aa40ef6ace984528850015ac108a2dff9e64556bd95668";
    });

    llvm-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu";
      sha256 =
        "62d2b7035165257b01bb85e5a13c86f053291d0b5c8dc81dd903cfcb6a73a704";
    });

    llvm-amdgpu-17_0 = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu-17_0";
      sha256 =
        "66d98e950b62cab3bd4a1c478b464aa877a75ddccaf30aa74fa6421aa27606dc";
    });

    llvm-amdgpu-17_0-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0-dev_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu-17_0-dev";
      sha256 =
        "65b950f5dd379d24c993a91ca5766383cb4a3c96bea9df8c6c9485def8d6dca4";
    });

    llvm-amdgpu-17_0-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-17.0-runtime_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu-17_0-runtime";
      sha256 =
        "ece7f2bdafbbbd8640e0699591c5f3c11754a1e384419b0a69d42da9fb9be9ed";
    });

    llvm-amdgpu-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-dev_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu-dev";
      sha256 =
        "75d310f30e43aeb75558f6d7ba7fd3f2b37a4db5a13fdd33a219d61386aa4326";
    });

    llvm-amdgpu-runtime = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/l/llvm-amdgpu/llvm-amdgpu-runtime_17.0.60103-1787201.22.04_i386.deb";
      name = "llvm-amdgpu-runtime";
      sha256 =
        "ef31d6e937fc860a8b38ee4f488ab48027e895e10e96fe851d3bafb8e0b945b8";
    });

    mesa-amdgpu-common-dev = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-common-dev_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-common-dev";
      sha256 =
        "f7bb67feef375b9b3ac3e981fb74d1c45b2c8e1a85412e0ae13cebc5890623bf";
    });

    mesa-amdgpu-multimedia = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia";
      sha256 =
        "fe2324374409c32aa4e2f2b6b1f478ff33206b89d6db84bceb4027baa4e817a2";
    });

    mesa-amdgpu-multimedia-devel = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-multimedia-devel_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-multimedia-devel";
      sha256 =
        "b4dd491d36ae51247ed411c6b9472b76f025a7c71e9c4b9656dfd01a5d676706";
    });

    mesa-amdgpu-omx-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-omx-drivers_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-omx-drivers";
      sha256 =
        "03ca917ae36919a90dadc2c376770f5fa59f3d3f5f1d3fecc4d627473c9a48db";
    });

    mesa-amdgpu-va-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-va-drivers_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-va-drivers";
      sha256 =
        "2edf5fe479353b116855db897c041ae78ca0d0e45c50c735b8194918f364b7aa";
    });

    mesa-amdgpu-vdpau-drivers = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/m/mesa-amdgpu/mesa-amdgpu-vdpau-drivers_24.1.0.60103-1787201.22.04_i386.deb";
      name = "mesa-amdgpu-vdpau-drivers";
      sha256 =
        "a16eba1a8031c67971bd57639cf4f076a1068ff500aab92fbd27d2942ca410ac";
    });

    va-amdgpu-driver-all = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.60103-1787201.22.04_i386.deb";
      name = "va-amdgpu-driver-all";
      sha256 =
        "69d6c0cbf712b9ffc879d970e47e5b7efc095e21257f6619bc3b862b241091ec";
    });

    wayland-protocols-amdgpu = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/main/w/wayland-protocols-amdgpu/wayland-protocols-amdgpu_1.32.60103-1787201.22.04_all.deb";
      name = "wayland-protocols-amdgpu";
      sha256 =
        "83c8d72ccbb6f2e0c60b89fb1017ef7a7c237fd340ffee8d4949c74ed94111a5";
    });

    amdgpu-pro-core = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/a/amdgpu-pro-core/amdgpu-pro-core_24.10-1787253.22.04_all.deb";
      name = "amdgpu-pro-core";
      sha256 =
        "08c50c9e28e558691acd9730be907a2510b47e9d0e8bbfe46ce02bc4a4a56f2d";
    });

    amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/amdgpu-pro-oglp_24.10-1787253.22.04_i386.deb";
      name = "amdgpu-pro-oglp";
      sha256 =
        "03f77d6c8d85a5163c765f16f13e35b8318c1388092aaf800e5e4c6b8f619c1c";
    });

    libegl1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_24.10-1787253.22.04_i386.deb";
      name = "libegl1-amdgpu-pro-oglp";
      sha256 =
        "151da11e9aaf7811ff6a0137153564edea0b89851a41b724e50c4068dbba4172";
    });

    libgl1-amdgpu-pro-oglp-dri = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_24.10-1787253.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-dri";
      sha256 =
        "1cc76d62422ba91eccb07208639835a86a2a8a208e24148c5a00ab8dadbe03f5";
    });

    libgl1-amdgpu-pro-oglp-glx = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_24.10-1787253.22.04_i386.deb";
      name = "libgl1-amdgpu-pro-oglp-glx";
      sha256 =
        "8c58d20c416ab44d5fdaa37e5195deb2a964e0c8130ab22764bf2ab3518f2548";
    });

    libgles1-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_24.10-1787253.22.04_i386.deb";
      name = "libgles1-amdgpu-pro-oglp";
      sha256 =
        "419f33e582fe36a09b8af210ed653f60de6a0546dc4e0f1c83cd27e83ddd6861";
    });

    libgles2-amdgpu-pro-oglp = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_24.10-1787253.22.04_i386.deb";
      name = "libgles2-amdgpu-pro-oglp";
      sha256 =
        "4c4a97b519cad2ee6eed4589a04da2a4bcbb66601685327735728a8bde3cc6cc";
    });

    vulkan-amdgpu-pro = (fetchurl {
      url =
        "https://repo.radeon.com/amdgpu/6.1.3/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_24.10-1787253.22.04_i386.deb";
      name = "vulkan-amdgpu-pro";
      sha256 =
        "11d2da8381c21bf48977d27298751a44ba22dbd581c7afe1376747a38b44b140";
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
      libllvm17_0-amdgpu
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
      llvm-amdgpu-17_0
      llvm-amdgpu-17_0-dev
      llvm-amdgpu-17_0-runtime
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
