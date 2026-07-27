{
  sources,

  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.inshellah) pname src;
  version = sources.inshellah.date;

  cargoLock = sources.inshellah.cargoLock."Cargo.lock";

  meta = {
    description = "The last word in nushell completions";
    homepage = "https://github.com/manic-systems/inshellah";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "inshellah";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
