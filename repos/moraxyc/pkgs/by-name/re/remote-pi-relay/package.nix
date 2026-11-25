{
  lib,
  pkg-config,
  rustPlatform,
  sqlite,

  sources,
  source ? sources.remote-pi-relay,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  cargoRoot = "relay";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoLock = source.cargoLock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];

  postInstall = ''
    mv $out/bin/{relay,remote-pi-relay}
  '';

  meta = {
    description = "WebSocket relay server for Remote Pi";
    homepage = "https://github.com/jacobaraujo7/remote_pi/tree/main/relay";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "remote-pi-relay";
    platforms = lib.platforms.unix;
  };
})
