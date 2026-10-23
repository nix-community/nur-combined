{
  autoPatchelfHook,
  lib,
  fetchGitHubReleaseAsset,
  installShellFiles,
  libgcc,
  mise,
  stdenvNoCC,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}: let
  inherit (stdenvNoCC) hostPlatform;

  version = "2026.10.17";
  tag = "v${version}";

  hashes = {
    aarch64-darwin = "sha256-KBxs1/TccH9OCzQ+4bIeiS6OtmNaaoZ50I91gnHYXv4=";
    aarch64-linux = "sha256-v2ylyz5Ele0Qx+alXWHfsej6trQbCFG9dB4V6Bq5Ns4=";
    x86_64-linux = "sha256-o9tXCDMAsXzqMkwaZSR1ufjQJcPJAMm1WpKWA5oVUAk=";
  };

  fetchAsset = args:
    fetchGitHubReleaseAsset (args
      // {
        inherit tag;
        owner = "jdx";
        repo = "mise";
      });

  completions = lib.mapAttrs (shell: hash:
    fetchAsset {
      inherit hash;
      asset = "mise.${shell}";
      extract = false;
    }) {
    bash = "sha256-su8z3uvo/9ngnDlUdPKrC+aufQRXOZ0/eQerEtBwwz0=";
    fish = "sha256-slrzjbmj9RWe3CM38XkOeStjlw5SpaYJtTeP/k4tYfg=";
    zsh = "sha256-rXE8PlGY9linJezVP2HVh0iDGVhpRNhExZEUhDVHew8=";
  };

  src = let
    inherit (hostPlatform.rust.platform) os;

    arch =
      if hostPlatform.isAarch64
      then hostPlatform.ubootArch
      else hostPlatform.efiArch;

    basename = lib.concatStringsSep "-" [mise.pname tag os arch];
    extension = "tar.xz";
  in
    fetchAsset {
      inherit extension;
      asset = "${basename}.${extension}";
      hash = hashes.${hostPlatform.system};
    };
in
  stdenvNoCC.mkDerivation {
    inherit src version;
    pname = "mise-bin";

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs =
      [
        installShellFiles
        writableTmpDirAsHomeHook
      ]
      ++ lib.optional hostPlatform.isLinux autoPatchelfHook;

    buildInputs = lib.optionals hostPlatform.isLinux [
      libgcc
    ];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = hostPlatform.isLinux;

    postPatch = lib.optionalString hostPlatform.isLinux ''
      autoPatchelf bin/mise
    '';

    installPhase = ''
      runHook preinstall

      installBin bin/mise
      installManPage man/man1/mise.1

      cp -R share $out

      install -Dm644 -t $out/share/doc/mise LICENSE README.md

      installShellCompletion \
        ${completions.bash} \
        ${completions.fish} \
        ${completions.zsh}

      mkdir -p $out/lib/mise
      touch $out/lib/mise/.disable-self-update

      runHook postInstall
    '';

    doInstallCheck = stdenvNoCC.buildPlatform.canExecute hostPlatform;

    nativeInstallCheckInputs = [versionCheckHook];

    meta =
      mise.meta
      // {
        changelog = "https://github.com/jdx/mise/blob/${tag}/CHANGELOG.md";
        maintainers = mise.meta.maintainers ++ [lib.maintainers.examosa];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = lib.attrNames hashes;
      };
  }
