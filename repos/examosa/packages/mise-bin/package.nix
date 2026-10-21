{
  lib,
  fetchGitHubReleaseAsset,
  installShellFiles,
  mise,
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

    nativeBuildInputs = [
      installShellFiles
      writableTmpDirAsHomeHook
    ];

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preinstall

      installBin bin/mise

      cp -R share $out

      install -Dm644 -t $out/share/doc/mise LICENSE README.md

      mkdir completions

      for shell in {ba,fi,z}sh; do
        $out/bin/mise completion $shell >completions/mise.$shell
      done

      mv completions/{mise.zsh,_mise}

      runHook postInstall
    '';

    inherit (mise) postInstall;

    meta =
      mise.meta
      // {
        changelog = "https://github.com/jdx/mise/blob/${tag}/CHANGELOG.md";
        maintainers = mise.meta.maintainers ++ [lib.maintainers.examosa];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = lib.attrNames hashes;
      };
  }
