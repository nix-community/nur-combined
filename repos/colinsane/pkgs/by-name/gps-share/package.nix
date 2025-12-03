{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage {
  pname = "gps-share";
  # require 0.3.1-unstable because 0.3.1 doesn't pass `doCheck`; tip has test fixes
  version = "0.3.1-unstable-2024-03-19";

  src = fetchFromGitHub {
    owner = "zeenix";
    repo = "gps-share";
    rev = "2b3955549643ae99ebe0681079d6fa1deaee20ea";
    hash = "sha256-GBO5b8yqQkEcmAEsvcLTZoQF8MOdutvNIbqk7OTVdFk=";
  };

  cargoHash = "sha256-WhYHFaSZfnlEmlXFLj7BIt0agMFuz07LcAXJ9ZOOrvY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "utility to share your GPS device on local network";
    homepage = "https://github.com/zeenix/gps-share";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
