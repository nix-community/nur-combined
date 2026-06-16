{
  lib,
  buildNpmPackage,
  importNpmLock,
  srcOnly,
  nodejs,

  sources,
  source ? sources.opencode-telegram-bot,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  inherit nodejs;

  patches = [ ./tempdir.patch ];

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;
  npmInstallFlags = [ "--ignore-scripts" ];

  preFixup = ''
    find "$out/lib/node_modules" -type f \( \
      -path '*/build/Makefile' -o \
      -path '*/build/*.mk' -o \
      -path '*/build/config.gypi' \
    \) -delete

    find "$out/lib/node_modules" -type d \( \
      -path '*/build/Release/.deps' -o \
      -path '*/build/Release/obj.target' -o \
      -path '*/build/Release/obj' \
    \) -prune -exec rm -rf '{}' +

    find "$out/lib/node_modules" -type d -empty -delete
  '';
  disallowedReferences = [ (srcOnly finalAttrs.nodejs) ];

  meta = {
    description = "OpenCode mobile client via Telegram";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    changelog = "https://github.com/grinev/opencode-telegram-bot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "opencode-telegram";
  };
})
