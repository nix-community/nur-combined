{ stdenv
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
, gcc9
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
}:
let
  gcc9-nolibc = wrapCCWith {
    inherit (gcc9) cc;
    bintools = wrapBintoolsWith {
      bintools = binutils-unwrapped;
      libc = null;
    };
    extraBuildCommands = ''
      sed -i '2i if ! [[ $@ == *'musl-gcc.specs'* ]]; then exec ${gcc9}/bin/gcc -L${glibc}/lib -L${glibc.static}/lib "$@"; fi' \
        $out/bin/gcc

      sed -i '2i if ! [[ $@ == *'musl-gcc.specs'* ]]; then exec ${gcc9}/bin/g++ -L${glibc}/lib -L${glibc.static}/lib "$@"; fi' \
        $out/bin/g++

      sed -i '2i if ! [[ $@ == *'musl-gcc.spec'* ]]; then exec ${gcc9}/bin/cpp "$@"; fi' \
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
  };
in
stdenv.mkDerivation {
  pname = "sgx-lkl";
  version = "2019-11-19";

  src = fetchFromGitHub {
    owner = "lsds";
    repo = "sgx-lkl";
    rev = "a4fc0cc6fea39f30d33783e55626afbff3c7a871";
    sha256 = "16j5j32wk70b8j4ghw41f8fqwv7wgfkgayd0v7xhns162sqqprm1";
    fetchSubmodules = true;
  };

  KBUILD_BUILD_HOST = "nix";

  postPatch = ''
    patchShebangs lkl/arch/lkl/scripts/headers_install.py
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
    gcc9-nolibc
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

  meta = with stdenv.lib; {
    description = "SGX-LKL Library OS for running Linux applications inside of Intel SGX enclaves";
    homepage = "https://github.com/lsds/sgx-lkl";
    license = licenses.mit;
    broken = true;
  };
}
