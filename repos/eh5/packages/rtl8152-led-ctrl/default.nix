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
    rev = "5fe64a80d2b84c7eb1fef92c5034411095cd6e13";
    hash = "sha256-Ie7pYGctO1XomKxUROZQX8L1k0HgPM4yHehIixivjwQ=";
  };

  cargoHash = "sha256-syekk6qBJwrIMGRZZkl6PM9Ep5p5huNK0tYfSndqFI4=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    libusb1
  ];
  strictDeps = true;

  meta = with lib; {
    description = "An eBPF-based Endpoint-Independent(Full Cone) NAT";
    homepage = "https://github.com/EHfive/${pname}";
    license = "Apache-2.0 OR MIT";
  };
}
