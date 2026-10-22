{
  autoPatchelfHook,
  lib,
  fetchGitHubReleaseAsset,
  installShellFiles,
  mise,
  stdenv,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
}: let
  inherit (stdenvNoCC) hostPlatform;

  version = "2026.10.15";
  tag = "v${version}";

  hashes = {
    aarch64-darwin = "sha256-wkIlzwnAIRpVZXVdOe5xRfsyAhLJZOjWy6nacZVOmx8=";
    x86_64-linux = "sha256-NEEt1oGEZkbEgyNWbbx5VUQjm5lx5HnFFwts9g+20OA=";
  };

  src = let
    inherit (hostPlatform.rust.platform) os;

    arch =
      if hostPlatform.isDarwin
      then hostPlatform.darwinArch
      else hostPlatform.efiArch;

    basename = lib.concatStringsSep "-" [mise.pname tag os arch];
    extension = "tar.xz";
  in
    fetchGitHubReleaseAsset {
      inherit extension tag;
      owner = "jdx";
      repo = "mise";
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
      stdenv.cc.cc.libgcc
    ];

    dontConfigure = true;
    dontBuild = true;

    postPatch = lib.optionalString hostPlatform.isLinux ''
      autoPatchelf bin/mise
    '';

    installPhase = ''
      runHook preinstall

      installBin bin/mise
      installManPage man/man1/mise.1

      cp -R share $out

      install -Dm644 -t $out/share/doc/mise LICENSE README.md

      installShellCompletion --cmd mise \
        --bash <($out/bin/mise completion bash) \
        --fish <($out/bin/mise completion fish) \
        --zsh <($out/bin/mise completion zsh)

      mkdir -p $out/lib/mise
      touch $out/lib/mise/.disable-self-update

      runHook postInstall
    '';

    meta =
      mise.meta
      // {
        changelog = "https://github.com/jdx/mise/blob/${tag}/CHANGELOG.md";
        maintainers = mise.meta.maintainers ++ [lib.maintainers.examosa];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = lib.attrNames hashes;
      };
  }
