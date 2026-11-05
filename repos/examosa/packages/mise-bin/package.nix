{
  lib,
  fetchGitHubReleaseAsset,
  installShellFiles,
  mise,
  stdenvNoCC,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}: let
  inherit (stdenvNoCC) hostPlatform;

  sources = import ./sources.nix {inherit fetchGitHubReleaseAsset;};
  inherit (sources) archives completions version;

  tag = "v${version}";
  src = archives.${hostPlatform.system};
in
  stdenvNoCC.mkDerivation {
    inherit src version;
    pname = "mise-bin";

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      installShellFiles
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preinstall

      installBin bin/mise
      installManPage man/man1/mise.1

      cp -R share $out

      install -Dm644 -t $out/share/doc/mise LICENSE README.md

      installShellCompletion \
        ${lib.escapeShellArgs (lib.attrValues completions)}

      mkdir -p $out/lib/mise
      touch $out/lib/mise/.disable-self-update

      runHook postInstall
    '';

    doInstallCheck = stdenvNoCC.buildPlatform.canExecute hostPlatform;

    nativeInstallCheckInputs = [versionCheckHook];

    passthru.updateScript = ./update.mjs;

    meta =
      mise.meta
      // {
        changelog = "https://github.com/jdx/mise/blob/${tag}/CHANGELOG.md";
        maintainers = mise.meta.maintainers ++ [lib.maintainers.examosa];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = lib.attrNames archives;
      };
  }
