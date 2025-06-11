{ lib, stdenv, fetchFromGitHub, fetchurl, libusbmuxd, libplist, libimobiledevice
, libusb1, readline, vim, xz, mbedtls, libirecovery, libimobiledevice-glue, }:
let

  ramdisk = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/c-rewrite/deps/ramdisk.dmg";
    sha256 = "62406cd27617fa3f00469425d221cfa801ba043a90a37ccad8146a2c7bb3ac1b";
  };

  kpf_pongo = fetchurl {
    url =
      "https://cdn.nickchan.lol/palera1n/artifacts/kpf/iOS15/checkra1n-kpf-pongo";
    sha256 = "d81dedd1ea5b9cdc9822a5498ff99dbaf3ea7b40bc81e90290802d7253164c76";
  };

  binpack = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/c-rewrite/deps/binpack.dmg";
    sha256 = "04dc0076d9c66bab65c719f8b14784ebda9903d425259c962f783b71342e0234";
  };

  pongo_bin = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/artifacts/kpf/iOS15/Pongo.bin";
    sha256 = "828d09fe801dd44b8af943324930bf4d4dab5f6cc1e2f300f2c40f294f0dce4a";
  };

  checkra1n_binaries = {
    "x86_64-darwin" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/preview/0.1337.3/checkra1n-macos";
      sha256 =
        "3bc1a0247dd9782b18de8945e3bb3b2dc740208b8c78f78634b80a7804a9f9be";
    };
    "aarch64-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/preview/0.1337.3/checkra1n-linux-arm64";
      sha256 =
        "078053c11e9a301f0e71b87b6b854e6c8a69c87972325dd0c90deeeba1c3cb70";
    };
    "armv7l-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/preview/0.1337.3/checkra1n-linux-armel";
      sha256 =
        "15dc243fc0e7ee77a9c5c5814667770d02be34ae12c2d77293d506d18b130ab2";
    };
    "i686-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/preview/0.1337.3/checkra1n-linux-x86";
      sha256 =
        "555e1a21ce50bed31826d49cefaeb4bd9099846cd2ac0c7ee0cfe649cb588887";
    };
    "x86_64-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/preview/0.1337.3/checkra1n-linux-x86_64";
      sha256 =
        "53154d87594cf67c56659f24547f1b5bb5336f84ea58c2d42f25a7b2df81a964";
    };
  };

in stdenv.mkDerivation rec {
  pname = "palera1n";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "palera1n";
    repo = "palera1n";
    rev = "v${version}";
    sha256 = "sha256-7c5upg9DxkDzNln8bmGYf+ko68wUwWoXp637WtqfJZo=";
  };

  buildInputs = [
    libusbmuxd
    libimobiledevice
    libplist.out
    mbedtls
    readline
    libusb1
    libirecovery
    libimobiledevice-glue
    (vim).xxd
    xz
  ];

  patchPhase = ''
     sed -i '/curl -Lfo/d' src/Makefile
     sed -i '/cp $(RESOURCES_DIR)\\/checkra1n-/d' src/Makefile

     sed -i '/-static/d' Makefile

    substituteInPlace src/Makefile \
     --replace-warn 'shell arch' 'shell uname -m' \
     --replace-warn '$(DEP)/lib/libusb-1.0.a' '${libusb1}/lib/libusb-1.0.so' 

    substituteInPlace Makefile \
     --replace-warn '$(shell git rev-list --count HEAD)' '1' \
     --replace-warn '$(shell git describe --dirty --tags --abbrev=7)' 'v${version}' \
     --replace-warn '$(shell git rev-parse --abbrev-ref HEAD)' 'main' \
     --replace-warn '$(shell git rev-parse HEAD)' '${src.rev}' \
     --replace-warn '$(DEP)/lib/libimobiledevice-1.0.a' '${libimobiledevice}/lib/libimobiledevice-1.0.so' \
     --replace-warn '$(DEP)/lib/libusbmuxd-2.0.a' '${libusbmuxd}/lib/libusbmuxd-2.0.so' \
     --replace-warn '$(DEP)/lib/libplist-2.0.a' '${libplist.out}/lib/libplist-2.0.so' \
     --replace-warn '$(DEP)/lib/libirecovery-1.0.a' '${libirecovery}/lib/libirecovery-1.0.so' \
     --replace-warn '$(DEP)/lib/libimobiledevice-glue-1.0.a' '${libimobiledevice-glue}/lib/libimobiledevice-glue-1.0.so' \
     --replace-warn '$(DEP)/lib/libmbedtls.a' '${mbedtls}/lib/libmbedtls.so' \
     --replace-warn '$(DEP)/lib/libmbedcrypto.a' '${mbedtls}/lib/libmbedcrypto.so' \
     --replace-warn '$(DEP)/lib/libmbedx509.a' '${mbedtls}/lib/libmbedx509.so' \
     --replace-warn '$(DEP)/lib/libreadline.a' '${readline}/lib/libreadline.so' 
  '';

  preBuild = ''
    mkdir -p /build/source/src/resources

    cp ${
      checkra1n_binaries."x86_64-darwin"
    } /build/source/src/resources/checkra1n-macos
    cp ${
      checkra1n_binaries."aarch64-linux"
    } /build/source/src/resources/checkra1n-linux-arm64
    cp ${
      checkra1n_binaries."armv7l-linux"
    } /build/source/src/resources/checkra1n-linux-armel
    cp ${
      checkra1n_binaries."i686-linux"
    } /build/source/src/resources/checkra1n-linux-x86
    cp ${
      checkra1n_binaries."x86_64-linux"
    } /build/source/src/resources/checkra1n-linux-x86_64


    cp ${ramdisk} /build/source/src/resources/ramdisk.dmg
    cp ${kpf_pongo} /build/source/src/resources/checkra1n-kpf-pongo
    cp ${binpack} /build/source/src/resources/binpack.dmg
    cp ${pongo_bin} /build/source/src/resources/Pongo.bin
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp  /build/source/src/${pname} $out/bin/${pname} 
    chmod +x $out/bin/${pname} 
  '';

  meta = with lib; {
    description =
      "Jailbreak for A8 through A11, T2 devices, on iOS/iPadOS/tvOS 15.0, bridgeOS 5.0 and higher.";
    homepage = "https://palera.in/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "palera1n";
  };
}
