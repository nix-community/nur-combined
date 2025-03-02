{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  udev,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-vibe";
  version = "unstable-2025-01-02";

  src = fetchFromGitHub {
    owner = "Shadlock0133";
    repo = pname;
    rev = "c645106c7d764d5f638fc1fda9424c007f19335d";
    hash = "sha256-Ld/k8detXJrzrq9HWJKCMDlQMMGbL1W/T0FN1d31z7s=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-qQLBq3jV3Ii/8KDTNRPi0r2KnJDtFIJURNx9zTsGDMQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    udev
    openssl
  ];

  meta = with lib; {
    mainProgram = "cargo-vibe";
    description = "Cargo x Buttplug.io";
    homepage = "https://github.com/shadlock0133/cargo-vibe";
    license = licenses.mit;
    maintainers = with maintainers; [_999eagle];
  };
}
