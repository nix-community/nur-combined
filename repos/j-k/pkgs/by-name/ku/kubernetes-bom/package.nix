{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "kubernetes-bom";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "bom";
    rev = "v${version}";
    hash = "sha256-dWuOAzZQSvmRN49O7w8uHW6xkaWJvHN/sGnppKrt1qQ=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };
  vendorHash = "sha256-Z9WAlByuzr4OqJ5WHsVarDY1TOewsbnv5O1yOZKTFhA=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/bom/pkg/version.GitVersion=v${version}"
    "-X sigs.k8s.io/bom/pkg/version.gitTreeState=clean"
  ];

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X sigs.k8s.io/bom/pkg/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X sigs.k8s.io/bom/pkg/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  preCheck = ''
    # remove tests that require networking
    rm pkg/spdx/spdx_unit_test.go
  '';

  postInstall = ''
    installShellCompletion --cmd bom \
      --bash <($out/bin/bom completion bash) \
      --fish <($out/bin/bom completion fish) \
      --zsh <($out/bin/bom completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/bom --help
    $out/bin/bom version | grep "v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/kubernetes-sigs/bom";
    description = "A utility to generate SPDX compliant Bill of Materials manifests";
    longDescription = ''
      bom is a general-purpose tool that can generate SPDX packages from
      directories, container images, single files, and other sources. The
      utility has a built-in license classifier that recognizes the 400+
      licenses in the SPDX catalog.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
