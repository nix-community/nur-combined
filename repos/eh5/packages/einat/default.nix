{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, rustfmt
, clang
, elfutils
, zlib
, enableIpv6 ? false
}: rustPlatform.buildRustPackage {
  pname = "einat";
  version = "unstable-2024-04-06";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = "einat-ebpf";
    rev = "9072b02613e9641433c0e80c2f902c4493e3555c";
    hash = "sha256-NyJY2j+Fp03r8f1o5FdDeKz+NUmPMflAUN3CPM9uMrA=";
  };

  cargoHash = "sha256-UEQD1wdg+QE/W6Gs5QUX3z3aGteRrVJ3oVP0TFrlppg=";

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
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
