{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  llvmPackages,
  bpftools,
  libbpf,
  elfutils,
  zlib,
  enableIpv6 ? false,
}:
rustPlatform.buildRustPackage rec {
  pname = "einat";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-dyjDzg6kpqjcne1Zke2f7KxAJMp2vAbfeyFGXoH+siE=";
  };

  cargoHash = "sha256-27Ia3+QPVC4+1TVW31S+cI3edDq+gBRnznPniBnbe44=";

  nativeBuildInputs = [
    pkg-config
    llvmPackages.clang-unwrapped
    llvmPackages.bintools-unwrapped
    bpftools
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libbpf
    elfutils
    zlib
  ];

  buildFeatures = [ "libbpf" ] ++ lib.optionals enableIpv6 [ "ipv6" ];

  doCheck = false;

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
