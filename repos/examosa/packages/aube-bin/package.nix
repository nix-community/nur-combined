{
  aube,
  fetchGitHubReleaseAsset,
  lib,
  installShellFiles,
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
    pname = "aube-bin";
    src = archives.${hostPlatform.system};

    __structuredAttrs = true;
    strictDeps = true;

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      installShellFiles
    ];

    installPhase = ''
      runHook preInstall

      installBin aube
      ln -rs $out/bin/aub{e,r}
      ln -rs $out/bin/aub{e,x}

      local completions=(aube.{ba,fi,z}sh) completion

      for completion in "''${completions[@]}"; do
        $JDX_USAGE_BIN generate completion "''${completion#*.}" aube \
          --file ${sources.usage} > $completion
      done

      installShellCompletion "''${completions[@]}"

      $JDX_USAGE_BIN generate manpage --file ${sources.usage} --out-file aube.1
      installManPage aube.1

      runHook postInstall
    '';

    doInstallCheck = stdenvNoCC.buildPlatform.canExecute hostPlatform;

    nativeInstallCheckInputs = [versionCheckHook];

    env.JDX_USAGE_BIN = lib.getExe usage;

    passthru.updateScript = [../../scripts/update.mjs "aube"];

    meta =
      aube.meta
      // {
        broken = lib.versionOlder usage.version "4";
        maintainers = aube.meta.maintainers ++ [lib.maintainers.examosa];
        platforms = lib.attrNames archives;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
  })
