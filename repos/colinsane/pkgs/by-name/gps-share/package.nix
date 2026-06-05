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

  postPatch = ''
    # this fixes `pgksMusl.gps-share`.
    cat >> "$cargoDepsCopy/source-registry-0/serial-0.3.4/Cargo.toml" <<'EOF'
      [target.'cfg(all(target_os = "linux", target_env = "musl"))'.dependencies]
      termios = "0.2.2"
      ioctl-rs = "0.1.5"
    EOF
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "utility to share your GPS device on local network";
    homepage = "https://github.com/zeenix/gps-share";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
