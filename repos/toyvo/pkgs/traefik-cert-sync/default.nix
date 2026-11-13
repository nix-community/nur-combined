{
  lib,
  writeShellApplication,
  bash,
  k3s,
  ...
}:

writeShellApplication {
  name = "traefik-cert-sync";
  # bash must be on PATH: sync.sh runs via `#!/usr/bin/env bash` and
  # systemd units start with a minimal PATH (this bit us on deploy).
  runtimeInputs = [
    bash
    k3s
  ];
  text = ''
    exec ${./sync.sh}
  '';
}
// {
  meta = {
    description = "Sync NixOS ACME wildcard certs into cluster TLS secrets";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "traefik-cert-sync";
    platforms = lib.platformsOf [ k3s ];
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
