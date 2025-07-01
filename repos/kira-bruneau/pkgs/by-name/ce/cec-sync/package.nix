{
  lib,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  libcec,
  udev,
  wayland,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cec-sync";
  version = "0-unstable-2025-06-30";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "f5ffec8cde82faecec28c89732ad4488dd360ea4";
    hash = "sha256-vpyu4RnS/vz4m33pLTiQA8As9o87eoSIoPnFdUo5+gA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-EaqELcaVqNINlobqmBhaqpk4gObckQ4Gx1Cf0Dq0jDk=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libcec
    udev
    wayland
  ];

  C_INCLUDE_PATH = "${libcec}/include/libcec";

  # No tests
  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Service for integrating Linux devices into a home theatre system over HDMI-CEC";
    homepage = "https://gitlab.com/kira-bruneau/cec-sync";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "cec-sync";
  };
})
