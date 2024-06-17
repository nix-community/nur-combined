{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libusb1
}:
rustPlatform.buildRustPackage rec {
  pname = "rtl8152-led-ctrl";
  version = "unstable-2024-06-17";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = pname;
    rev = "01f6cfbb611564c6f42ab0c6db21c84b49daa321";
    hash = "sha256-/vdocAu2wcKJ28qyYWe+SlD+lQXv2b1xulWKbkAUA2w=";
  };

  cargoHash = "sha256-syekk6qBJwrIMGRZZkl6PM9Ep5p5huNK0tYfSndqFI4=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    libusb1
  ];
  strictDeps = true;

  meta = {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/${pname}";
    license = "Apache-2.0 OR MIT";
  };
}
