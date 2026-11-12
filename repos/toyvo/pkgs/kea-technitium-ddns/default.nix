{
  lib,
  bun,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "kea-technitium-ddns";
  runtimeInputs = [ bun ];
  text = ''
    exec bun ${./src}/ddns.ts
  '';
}
// {
  meta = {
    description = "Kea DHCP to Technitium dynamic DNS sync";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "kea-technitium-ddns";
    platforms = lib.platformsOf [ bun ];
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
