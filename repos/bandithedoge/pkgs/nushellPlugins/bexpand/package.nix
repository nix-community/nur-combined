{
  sources,

  lib,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.nu-plugin-bexpand) pname src;
  version = sources.nu-plugin-bexpand.date;

  cargoLock = sources.nu-plugin-bexpand.cargoLock."Cargo.lock";

  meta = {
    description = "Bash style brace expansion for nushell";
    homepage = "https://forge.axfive.net/Taylor/nu-plugin-bexpand";
    license = lib.licenses.mpl20;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_bexpand";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
