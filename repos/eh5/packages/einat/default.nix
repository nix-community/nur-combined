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
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-T2Agt3ojSQp2dvnm4XJtvDhWC5oK50hHHmUVw9ODFKM=";
  };

  cargoHash = "sha256-S+/EidoH/nzlxdJWf5EnSfFC2oqm4j/fJ1pGxODCwQI=";

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

  buildFeatures = [
    "libbpf"
  ]
  ++ lib.optionals enableIpv6 [ "ipv6" ];

  doCheck = false;

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
