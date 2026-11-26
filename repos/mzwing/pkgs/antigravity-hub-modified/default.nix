{
  lib,
  stdenv,
  cctools,
  darwin,
  antigravity-hub,
  antigravity-cli-modified,
  unlockContext ? true,
  prompts ? {},
}: let
  languageServer =
    if stdenv.hostPlatform.isDarwin
    then "$out/Applications/Antigravity.app/Contents/Resources/bin/language_server"
    else "$out/share/antigravity/resources/bin/language_server";
in
  antigravity-hub.overrideAttrs (old: {
    pname = "antigravity-hub-modified";

    nativeBuildInputs = old.nativeBuildInputs ++ lib.optionals stdenv.hostPlatform.isDarwin [darwin.sigtool cctools];

    # Runs before autoPatchelfHook rewrites the ELF on Linux
    postInstall = ''
      ${(antigravity-cli-modified.override {inherit unlockContext prompts;}).patchBinary languageServer}
      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        codesign --force --sign - --preserve-metadata identifier,entitlements,flags ${languageServer}
      ''}
    '';

    meta =
      old.meta
      // {
        description = "Antigravity desktop with its language server's context clamp lifted and built-in prompts replaceable";
        maintainers = [{name = "mzwing";}];
      };
  })
