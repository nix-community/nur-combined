{
  lib,
  buildNpmPackage,
  importNpmLock,

  sources,
  source ? sources.pi-acp,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  # Installed as a standalone ACP agent (bin: pi-acp), not a Pi extension, so keep the npm layout.
  meta = {
    description = "ACP adapter for the pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    mainProgram = "pi-acp";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
