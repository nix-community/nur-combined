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
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-0S4od60X5j7wWD9mV/jUuJ8EwJ+OLYM2bnUTjr0pozo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-IX95AnLYMtVrkQY/nLEgTq44m6I1z/HiT7MXVGv2epM=";

  nativeBuildInputs = [
    pkg-config
    llvmPackages.clang-unwrapped
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
