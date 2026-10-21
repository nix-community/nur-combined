{
  writeShellApplication,
  nushell,
  nix,
  dpkg,
}:
writeShellApplication {
  name = "update-115life";
  runtimeInputs = [
    nushell
    nix
    dpkg
  ];
  text = ''exec nu ${../../scripts/update-115life.nu} "$@"'';
}
