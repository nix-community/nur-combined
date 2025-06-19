{ lib, stdenv, fetchFromGitHub, fetchurl, libusbmuxd, libplist, libimobiledevice
, libusb1, readline, vim, xz, mbedtls, libirecovery, libimobiledevice-glue }:
let

  checkra1n-all-binaries =
    import ./../checkra1n-all-binaries { inherit lib stdenv fetchurl; };

  ramdisk = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/c-rewrite/deps/ramdisk.dmg";
    sha256 = "03908ghycf6dq6nk0w21hws0qx7yqd4mgwn731hgy02qfs302pwd";
  };

  kpf_pongo = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/artifacts/kpf/iOS15/checkra1n-kpf-pongo";
    sha256 = "0xjc2r9p4bc0j01fk0dw81xymwxskpwqyjd54acdr72vxb8ys7fq";
  };

  binpack = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/c-rewrite/deps/binpack.dmg";
    sha256 = "0l12w7r51gzgxf483srgvhxzi5x6yjfk910bmd6fk05d024drzzc";
  };

  pongo_bin = fetchurl {
    url = "https://cdn.nickchan.lol/palera1n/artifacts/kpf/iOS15/Pongo.bin";
    sha256 = "0jnf1m7jj3y4y80g7qn1digsnkadpwq4jcj3z654pm0xh3z0k3c2";
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
     --replace-warn '$(DEP)/lib/libreadline.a' '${readline}/lib/libreadline.so' \
     --replace-warn '-static' ""
  '';

  preBuild = ''
    mkdir -p $PWD/src/resources

    cp ${checkra1n-all-binaries}/bin/checkra1n-x86_64-darwin src/resources/checkra1n-macos
    cp ${checkra1n-all-binaries}/bin/checkra1n-aarch64-linux src/resources/checkra1n-linux-arm64
    cp ${checkra1n-all-binaries}/bin/checkra1n-armv7l-linux src/resources/checkra1n-linux-armel
    cp ${checkra1n-all-binaries}/bin/checkra1n-i686-linux src/resources/checkra1n-linux-x86
    cp ${checkra1n-all-binaries}/bin/checkra1n-x86_64-linux src/resources/checkra1n-linux-x86_64

    cp ${ramdisk} src/resources/ramdisk.dmg
    cp ${kpf_pongo} src/resources/checkra1n-kpf-pongo
    cp ${binpack} src/resources/binpack.dmg
    cp ${pongo_bin} src/resources/Pongo.bin
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp  src/${pname} $out/bin/${pname} 
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
