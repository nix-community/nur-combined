{
  lib,
  bun,
  iproute2,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "network-inventory";
  runtimeInputs = [
    bun
    iproute2
  ];
  text = ''
    exec bun ${./inventory.ts}
  '';
}
// {
  meta = {
    description = "Network device inventory collector for Prometheus";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "network-inventory";
    platforms = lib.platformsOf [
      bun
      iproute2
    ];
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
