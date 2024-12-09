{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  rustfmt,
  llvmPackages,
  bpftools,
  libbpf,
  elfutils,
  zlib,
  enableIpv6 ? false,
}:
rustPlatform.buildRustPackage rec {
  pname = "einat";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-YKc5ZIhZ19H4wEpTbYpSNE/PuIpQCaDnxgCNqulEuYM=";
  };

  cargoHash = "sha256-IE3hiMQOY+k9tPrqlzmJJHX+4WvBBtvqwO0kSKTctNI=";

  nativeBuildInputs = [
    pkg-config
    rustfmt
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

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
