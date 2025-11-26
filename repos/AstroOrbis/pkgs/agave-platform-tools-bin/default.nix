{
  stdenv,
  fetchFromGitHub,
  lib,
  rustPlatform,
  udev,
  protobuf,
  rocksdb_8_3,
  installShellFiles,
  pkg-config,
  openssl,
  bash,
  git,
  python310,
  curl,
  patchelf,
  fetchurl,
  autoPatchelfHook,
  libxml2,
  glibc,
  zlib,
  ncurses,
  libedit,
  xz,
}:
let
  version = "1.52";
in
stdenv.mkDerivation rec {
  pname = "agave-platform-tools-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/anza-xyz/platform-tools/releases/download/v${version}/platform-tools-linux-x86_64.tar.bz2";
    hash = "sha256-izhh6T2vCF7BK2XE+sN02b7EWHo94Whx2msIqwwdkH4=";
  };

  nativeBuildInputs = [
    pkg-config
    patchelf
    autoPatchelfHook
  ];

  buildInputs = [
    python310
    libxml2
    glibc
    zlib
    ncurses
    libedit
    xz
  ];

  unpackPhase = ''
    tar -xjf $src -C .
    rm llvm/lib/python3.10/dist-packages/lldb/{_lldb.cpython-310-x86_64-linux-gnu.so,lldb-argdumper}
    ln -s ../../../liblldb.so llvm/lib/python3.10/dist-packages/lldb/_lldb.cpython-310-x86_64-linux-gnu.so 
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libxml2.so.2"
    "libedit.so.2"
  ];

  prePatchPhase = ''
    patchelf --replace-needed libxml2.so.2 libxml2.so llvm/lib/liblldb.so.19.1.7-rust-dev
    patchelf --replace-needed libedit.so.2 libedit.so llvm/lib/liblldb.so.19.1.7-rust-dev
  '';

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';

  meta = with lib; {
    description = "Solana-Agave platform tools";
    homepage = " https://solana.com ";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
