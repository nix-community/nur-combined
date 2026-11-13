{
  lib,
  writeShellApplication,
  k3s,
  ...
}:

writeShellApplication {
  name = "traefik-cert-sync";
  runtimeInputs = [ k3s ];
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
