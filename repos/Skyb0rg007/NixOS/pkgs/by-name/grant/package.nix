{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "grant";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "anchore";
    repo = "grant";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BoPcXAdy5jggwxPQtjIswHP03xLCqD6S6R0+Yj7AqfM=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  vendorHash = "sha256-8BJSyHfGABQJ1rmOFq++bKq+Q08XdVtOnV1IklkBHJ8=";

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "cmd/grant" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.gitDescription=v${finalAttrs.version}"
    "-X=main.gitTreeState=clean"
  ];

  preBuild = ''
    ldflags+=" -X main.gitCommit=$(cat COMMIT)"
    ldflags+=" -X main.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  postInstall = ''
    installShellCompletion --cmd grant \
      --bash <($out/bin/grant completion bash) \
      --fish <($out/bin/grant completion fish) \
      --zsh <($out/bin/grant completion zsh)
  '';

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool for checking licenses";
    longDescription = ''
      Grant is a CLI tool and Go library for checking licenses in container
      images, SBOMs, and filesystems. Works seamlessly with Syft for license
      investigation and policy enforcement.
    '';
    homepage = "https://github.com/anchore/grant";
    changelog = "https://github.com/anchore/grant/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "grant";
  };
})
