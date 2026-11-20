{
  fetchGitHubReleaseAsset,
  installShellFiles,
  lib,
  mise,
  stdenvNoCC,
  usage,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}: let
  inherit (stdenvNoCC) hostPlatform;
  sources = import ./sources.nix {inherit fetchGitHubReleaseAsset;};
  inherit (sources) archives;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit (sources) version;
    pname = "mise-bin";
    src = archives.${hostPlatform.system};

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      installShellFiles
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      installBin bin/mise
      installManPage man/man1/mise.1

      cp -R share $out

      install -Dm444 -t $out/share/doc/mise LICENSE README.md

      local completions=(mise.{ba,fi,z}sh) completion

      for completion in "''${completions[@]}"; do
        $JDX_USAGE_BIN generate completion "''${completion#*.}" mise \
          --file ${sources.usage} > $completion
      done

      installShellCompletion "''${completions[@]}"

      install -d $out/lib/mise
      touch $out/lib/mise/.disable-self-update

      runHook postInstall
    '';

    doInstallCheck = stdenvNoCC.buildPlatform.canExecute hostPlatform;

    nativeInstallCheckInputs = [
      versionCheckHook
      writableTmpDirAsHomeHook
    ];

    env.JDX_USAGE_BIN = lib.getExe usage;

    passthru.updateScript = [../../scripts/update.mjs "mise"];

    meta =
      mise.meta
      // {
        changelog = "https://github.com/jdx/mise/blob/${finalAttrs.src.tag}/CHANGELOG.md";
        maintainers = mise.meta.maintainers ++ [lib.maintainers.examosa];
        platforms = lib.attrNames archives;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
  })
