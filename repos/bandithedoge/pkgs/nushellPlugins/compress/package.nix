{
  fetchFromGitHub,
  lib,
  nix-update-script,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu-plugin-compress";
  version = "0.2.5";
  src = fetchFromGitHub {
    owner = "yybit";
    repo = "nu_plugin_compress";
    rev = finalAttrs.version;
    hash = "sha256-sm26bkBgZqPWaCUJxQqKiA8M/eROh6sCnIRrgxbJPTo=";
  };

  cargoHash = "sha256-HAnqF81WIDtrkpxlcXRgrp5qRl1PMj/dYBTjSaVpgkw=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nushell plugin for compression and decompression, supporting zstd, gzip, bzip2, and xz";
    homepage = "https://github.com/yybit/nu_plugin_compress";
    license = lib.licenses.asl20;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_compress";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
