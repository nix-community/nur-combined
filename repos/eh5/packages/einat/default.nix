{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, rustfmt
, clang
, elfutils
, zlib
, enableIpv6 ? false
}:
rustPlatform.buildRustPackage rec {
  pname = "einat";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "v${version}";
    hash = "sha256-JBYrnXydmaPNw0wmd1X5MFHMTBchY1PURgLdybMn+Gc=";
  };

  cargoHash = "sha256-OnYzX+RQDqegb795HY4cuiqYnjEOftGBPFxq+MAPzmQ=";

  nativeBuildInputs = [
    pkg-config
    rustfmt
    clang
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
