{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libusb1,
}:
rustPlatform.buildRustPackage rec {
  pname = "rtl8152-led-ctrl";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "EHfive";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Cz3BEWKew2X7O3whIVqb9ZqKfth+BQyBFQ8bf9m3WXM=";
  };

  cargoHash = "sha256-CogZg3+FITLl5ua3cCFKGdCETt/kNirFbRuIdpzqrn8=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    libusb1
  ];
  strictDeps = true;

  meta = {
    description = "A tool to configure LEDs on RTL8152/RTL8153 series USB NICs.";
    homepage = "https://github.com/EHfive/${pname}";
    license = "Apache-2.0 OR MIT";
  };
}
