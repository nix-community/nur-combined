{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "systemd-udp-proxy";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SharkBaitDLS";
    repo = "systemd-udp-proxy";
    tag = finalAttrs.version;
    hash = "sha256-D3JgSg5isGNmXV+nhQVVyoEipEN1nrtSyY/qQcqW+Ic=";
  };

  cargoHash = "sha256-631jknM6TlouPAOjUlQqpmWZzzXjrIrX8Nu3WXdQGho=";

  meta = {
    description = "A systemd socket-aware non-transparent UDP proxy";
    homepage = "https://github.com/SharkBaitDLS/systemd-udp-proxy";
    license = lib.licenses.mit;
    mainProgram = "systemd-udp-proxy";
  };
})
