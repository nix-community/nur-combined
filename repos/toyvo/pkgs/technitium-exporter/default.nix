{
  lib,
  bun,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "technitium-exporter";
  runtimeInputs = [ bun ];
  text = ''
    exec bun ${./exporter.ts}
  '';
}
// {
  meta = {
    description = "Prometheus exporter for Technitium DNS Server";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "technitium-exporter";
    platforms = lib.platformsOf [ bun ];
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
