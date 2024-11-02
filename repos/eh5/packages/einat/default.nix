{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, rustfmt
, llvmPackages
, elfutils
, zlib
, enableIpv6 ? false
}:
rustPlatform.buildRustPackage rec {
  pname = "einat";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-vVamFD/zbMZMor89a5V5v0HsgPZKsmdYimmA5Ti6E9U=";
  };

  cargoHash = "sha256-DBc6QS+GLB68er4GDCMCRIYyI1HSRJeUztF8lkcL1Wc=";

  patches = [
    ./0001-fix-ebpf-always-pull-first-header-bytes.patch
  ];

  nativeBuildInputs = [
    pkg-config
    rustfmt
    llvmPackages.clang-unwrapped
    rustPlatform.bindgenHook
    elfutils
    zlib
  ];

  buildInputs = [
    elfutils
    zlib
  ];

  buildFeatures = lib.optionals enableIpv6 [ "ipv6" ];

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/einat-ebpf";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
