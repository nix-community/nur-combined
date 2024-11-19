{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  rustfmt,
  llvmPackages,
  libbpf,
  elfutils,
  zlib,
  enableIpv6 ? false,
}:
rustPlatform.buildRustPackage rec {
  pname = "einat";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-g0/MMln0amiar2noBbTdncioPrytWGeeuX6J41f3AwI=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "self_cell-1.0.4" = "sha256-LDbQqDax5gp/zPfEMYknRiOORccpkY0S6mdai1/DpNk=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    rustfmt
    llvmPackages.clang-unwrapped
    llvmPackages.bintools-unwrapped
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libbpf
    elfutils
    zlib
  ];

  buildFeatures = [ "libbpf" ] ++ lib.optionals enableIpv6 [ "ipv6" ];

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
