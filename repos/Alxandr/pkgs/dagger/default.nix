{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  git,
  installShellFiles,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "dagger";
  version = "0.21.9";

  src = fetchFromGitHub {
    owner = "dagger";
    repo = "dagger";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ZI9R0fp0qFGQljfNgrwKj071a10ZVpNMmEKHDFNUW3c=";
    fetchSubmodules = true;
  };

  # Some native dependencies are not properly vendored without this
  proxyVendor = true;
  vendorHash = "sha256-GNVVwSdsNuGOrApJ6oXNMWv5C0S0tFVLNWKc+R9Ld1s=";

  subPackages = [
    "cmd/dagger"
  ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X github.com/dagger/dagger/engine.Version=v${finalAttrs.version}"
    "-X github.com/dagger/dagger/engine.Tag=v${finalAttrs.version}"
  ];

  nativeCheckInputs = [
    git
  ];

  checkFlags =
    let
      skippedTests = [
        # requires network access
        "TestCloudEngineUnauth"
        "TestDaggerCMD/TestShellAutocomplete"
      ];

      skipRegex = lib.concatMapStringsSep "|" lib.strings.escapeRegex skippedTests;
    in
    [
      "-skip=${skipRegex}$"
    ];

  preCheck = ''
    # Some tests expect $HOME to exist and be writable
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    echo "CHECK FLAGS: ''${checkFlags[@]}"
    #exit 1
  '';

  postInstall = ''
    installShellCompletion --cmd dagger \
    --bash <($out/bin/dagger completion bash) \
    --fish <($out/bin/dagger completion fish) \
    --zsh <($out/bin/dagger completion zsh)
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Dagger is an integrated platform to orchestrate the delivery of applications";
    homepage = "https://dagger.io";
    license = lib.licenses.asl20;

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
