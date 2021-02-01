{ lib
, stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchFromGitLab
, fetchurl
, linuxHeaders
, libtool
, libgcc
, pkgconfig
, bc
, bison
, flex
, libgcrypt
, gettext
, python3
, wrapCCWith
, wrapBintoolsWith
, binutils-unwrapped
, glibc
, rsync
, m4
, protobufc
, protobuf
, json_c
, curl
, openssl
, gcc
}:
let
  gcc-nolibc = wrapCCWith {
    inherit (gcc) cc;
    bintools = wrapBintoolsWith {
      bintools = binutils-unwrapped;
      libc = null;
    };
    extraBuildCommands = ''
      sed -i '2i if ! [[ $@ == *'musl-gcc.specs'* ]]; then exec ${gcc}/bin/gcc -L${glibc}/lib -L${glibc.static}/lib "$@"; fi' \
        $out/bin/gcc

      sed -i '2i if ! [[ $@ == *'musl-gcc.specs'* ]]; then exec ${gcc}/bin/g++ -L${glibc}/lib -L${glibc.static}/lib "$@"; fi' \
        $out/bin/g++

      sed -i '2i if ! [[ $@ == *'musl-gcc.spec'* ]]; then exec ${gcc}/bin/cpp "$@"; fi' \
        $out/bin/cpp
    '';
  };
  srcs = {
    cryptsetup = fetchFromGitLab {
      owner = "cryptsetup";
      repo = "cryptsetup";
      rev = "v2.0.2";
      sha256 = "0g4m9g3fkyb8a0pw9r2idxkhvd4jwdybls2v4y38pgbl3fnbg9f0";
    };

    devicemapper = fetchFromGitHub {
      owner = "lvmteam";
      repo = "lvm2";
      rev = "v2_02_98";
      sha256 = "1raczn00980ivkpya48c0lws7634fscfywrnpsyhc3xg9bcrwzif";
    };

    utillinux = fetchurl {
      url = "https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/snapshot/util-linux-2.29.2.tar.gz";
      sha256 = "0vcb3h0ys31yy84ipd22za6i4y1h6l1bpcljawrgialz84bvpaib";
    };

    popt = fetchurl {
      url = "https://deb.debian.org/debian/pool/main/p/popt/popt_1.16.orig.tar.gz";
      sha256 = "1j2c61nn2n351nhj4d25mnf3vpiddcykq005w2h6kw79dwlysa77";
    };

    json-c = fetchFromGitHub {
      owner = "json-c";
      repo = "json-c";
      rev = "json-c-0.13.1-20180305";
      sha256 = "1qmmyczis74aa2w66szn4w1wyms2wpr38q9kky33qa8xk932q1rr";
    };

    protobuf-c = fetchurl {
      url = "https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.1/protobuf-c-1.3.1.tar.gz";
      sha256 = "0rr2kn7804cvhdm6lzz04gz76vy0fzj15dijbr17nv8x34x2sisi";
    };

    wireguard = fetchurl {
      url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-0.0.20190227.tar.xz";
      sha256 = "0ybzycpjjidyiz88kkh67abvp3y30f34252dwpgf3ncj4vyjdnzw";
    };

    host-musl = fetchFromGitHub {
      owner = "lsds";
      repo = "musl";
      rev = "1691b23955590d1eb66a11158fdd91c86337e886";
      sha256 = "0ffl7b9qi6jl5jr42230xsasbc49sxsy77lm2di90gqvl3gpydc8";
    };

    lkl = fetchFromGitHub {
      owner = "lkl";
      repo = "linux";
      rev = "58dc2025bf469d880d76250e682dd8e4ed225a6b";
      sha256 = "000m1965x8ns0fkmhln6598rrafib7sd373g7c1yfd8v1laxf443";
    };

    sgx-lkl-musl = fetchFromGitHub {
      owner = "lsds";
      repo = "sgx-lkl-musl";
      rev = "22c91c211aaf4048a4f034084bb7fa202bd6071c";
      sha256 = "16x02jv78mhysvl81px48mc1zjszjxjda8zqpzdk1937jy6yrqis";
    };
  };
in
stdenv.mkDerivation {
  pname = "sgx-lkl";
  version = "2019-11-19";

  # We don't fetch submodules here because downloading the linux repo as git takes too long; tarballs are much faster
  src = fetchFromGitHub {
    owner = "lsds";
    repo = "sgx-lkl";
    rev = "a4fc0cc6fea39f30d33783e55626afbff3c7a871";
    sha256 = "1d7dj7gdzyn3rp7achkr8ar29pg0lijh7m7yd1n26gkbvqljrahp";
  };

  KBUILD_BUILD_HOST = "nix";

  postPatch = ''
    rm -r lkl sgx-lkl-musl host-musl
    cp -r ${srcs.sgx-lkl-musl} sgx-lkl-musl && chmod -R u+w sgx-lkl-musl
    cp -r ${srcs.lkl} lkl && chmod -R u+w lkl
    cp -r ${srcs.host-musl} host-musl && chmod -R u+w host-musl

    patchShebangs lkl/arch/lkl/scripts/headers_install.py
    patchShebangs host-musl/configure
    pushd third_party
    cp -r ${srcs.cryptsetup} cryptsetup && chmod -R u+w cryptsetup
    cp -r ${srcs.devicemapper} devicemapper && chmod -R u+w devicemapper
    cp -r ${srcs.json-c} json-c && chmod -R u+w json-c

    mkdir util-linux popt protobuf-c wireguard

    tar -C util-linux --strip 1 -xf ${srcs.utillinux}
    tar -C popt --strip 1 -xf ${srcs.popt}
    tar -C protobuf-c --strip 1 -xf ${srcs.protobuf-c}
    tar -C wireguard --strip 1 -xf ${srcs.wireguard}
    ls -la
    popd
  '';

  FORCE_SUBMODULES_VERSION = "true";

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  strictDeps = true;

  buildInputs = [
    linuxHeaders
    libgcc
    json_c
    curl
    linuxHeaders
    protobuf
    protobufc
  ];

  nativeBuildInputs = [
    autoconf
    automake
    m4
    libtool
    libgcrypt
    gettext
    gcc-nolibc
    pkgconfig
    bc
    bison
    flex
    rsync
    python3
    protobuf
    protobufc
    openssl
  ];

  meta = with lib; {
    description = "SGX-LKL Library OS for running Linux applications inside of Intel SGX enclaves";
    homepage = "https://github.com/lsds/sgx-lkl";
    license = licenses.mit;
  };
}
