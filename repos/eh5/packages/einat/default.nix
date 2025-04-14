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
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-O9SwBSLXB3t1lIULt7JDJq8cCY7sFRMuRPeN6tjV1jw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-D6jzu+6aqqHsjF6oGs83NzSAydA1/7mK3hwC6CH7aes=";

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

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
