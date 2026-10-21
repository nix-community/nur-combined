{
  openssl,
  pkg-config,
  rustPlatform,
  shard,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "${shard.pname}-cli";
  inherit (shard) src version cargoDeps;

  __structuredAttrs = true;
  strictDeps = true;

  cargoRoot = "./.";
  buildAndTestSubdir = "launcher";

  postPatch = ''
    substituteInPlace launcher/Cargo.toml \
      --replace-fail '"rustls-tls"' '"native-tls"'
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = 1;

  meta = shard.meta // {
    description = "CLI for the minimal, content-addressed Minecraft launcher";
    mainProgram = "shard";
  };
})
