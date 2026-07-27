{
  sources,

  lib,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.nu-plugin-compress) pname version src;

  cargoLock = sources.nu-plugin-compress.cargoLock."Cargo.lock";

  meta = {
    description = "Nushell plugin for compression and decompression, supporting zstd, gzip, bzip2, and xz";
    homepage = "https://github.com/yybit/nu_plugin_compress";
    license = lib.licenses.asl20;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_compress";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
