{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  bpftools,
  clang,
  llvmPackages,
  libbpf,
  xdp-tools,
  libffi,
  elfutils,
  zlib,
  zstd,
  ronn,
}:

stdenv.mkDerivation {
  pname = "mimic-bpf";
  version = "unstable-2024-03-22";

  src = fetchFromGitHub {
    owner = "hack3ric";
    repo = "mimic";
    rev = "b1f0701b90b7a070e3aa2bd701ee409f79353824";
    sha256 = "19y11akj67n3x0gna08wrrip4kv110m5jzp5mbicwsb6ay0vaw72";
  };

  nativeBuildInputs = [
    pkg-config
    bpftools
    clang
    llvmPackages.llvm # for llvm-strip
    ronn
  ];

  buildInputs = [
    libbpf
    xdp-tools
    libffi
    elfutils
    zlib
    zstd
  ];

  hardeningDisable = [ "zerocallusedregs" ];

  makeFlags = [
    "BPF_CC=clang"
    "BPFTOOL=bpftool"
    "LLVM_STRIP=llvm-strip"
    "CHECKSUM_HACK=kprobe"
  ];

  buildFlags = [
    "build-cli"
    "build-tools"
    "generate-manpage"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/man/man1
    cp out/mimic $out/bin/
    cp out/mimic.1.gz $out/share/man/man1/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A UDP to TCP obfuscator designed to bypass UDP QoS and port blocking";
    homepage = "https://github.com/hack3ric/mimic";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "mimic";
    platforms = platforms.linux;
  };
}
