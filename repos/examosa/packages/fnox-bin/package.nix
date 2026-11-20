{
  fetchGitHubReleaseAsset,
  installShellFiles,
  lib,
  stdenvNoCC,
  usage,
  versionCheckHook,
}: let
  inherit (stdenvNoCC) hostPlatform;
  sources = import ./sources.nix {inherit fetchGitHubReleaseAsset;};
  inherit (sources) archives version;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version;
    pname = "fnox";
    src = archives.${hostPlatform.system};

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      installShellFiles
    ];

    installPhase = ''
      runHook preInstall

      installBin fnox

      local completions=(fnox.{ba,fi,z}sh) completion

      for completion in "''${completions[@]}"; do
        $JDX_USAGE_BIN generate completion "''${completion#*.}" fnox \
          --file ${sources.usage} > $completion
      done

      installShellCompletion "''${completions[@]}"

      $JDX_USAGE_BIN generate manpage --file ${sources.usage} --out-file fnox.1
      installManPage fnox.1

      runHook postInstall
    '';

    doInstallCheck = stdenvNoCC.buildPlatform.canExecute hostPlatform;

    nativeInstallCheckInputs = [versionCheckHook];

    env.JDX_USAGE_BIN = lib.getExe usage;

    passthru.updateScript = [../../scripts/update.mjs "fnox"];

    meta = {
      broken = lib.versionOlder usage.version "6";
      description = "Encrypted/remote secret manager";
      homepage = "https://github.com/jdx/fnox";
      changelog = "https://github.com/jdx/fnox/blob/refs/tags/v${version}/CHANGELOG.md";
      license = lib.licenses.mit;
      maintainers = [lib.maintainers.examosa];
      mainProgram = "fnox";
      platforms = lib.attrNames archives;
    };
  })
