{
  lib,
  buildNpmPackage,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nix-update-script,

  sources,
  source ? sources.deepseek-harness-tui,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-YGGVIWXUZscnUjHEX2Wb3VHW5eEhD58SIne0xXRPPgg=";
  };

  nativeBuildInputs = [ pnpm_11 ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    appDir="$out/lib/node_modules/dsh-cc-tui"
    mkdir -p "$appDir"

    cp -r package.json cordis.patch.yml cordis.yml skills lib "$appDir/"

    cp -r node_modules "$appDir/node_modules"

    runHook postInstall
  '';

  passthru = {
    dshBundles = [ "dsh-cc-tui" ];
    # nix-update auto -u
    updateScript = nix-update-script { extraArgs = "--version=skip"; };
  };

  meta = {
    description = "Claude Code style interactive TUI front door for DeepSeek Harness agents";
    homepage = "https://github.com/ccch1mneyyy/dsh-TUI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
  };
})
