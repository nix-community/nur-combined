{
  # keep-sorted start
  buildGo126Module,
  fetchgit,
  git,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
}:
buildGo126Module rec {
  pname = "tg";
  version = "0.1.0";

  src = fetchgit {
    url = "https://tangled.org/secluded.site/tg";
    tag = "v${version}";
    hash = "sha256-0ugbaL2wyhLniu8oQc8aKgLb1CWrVJyauvUir/Cc+tA=";
  };

  vendorHash = "sha256-yifZoO8dBh9/oCkVlwYmtXJ+txzfPr8N/D2yMehph8E=";
  proxyVendor = true;

  subPackages = ["cmd/tg"];

  nativeBuildInputs = [installShellFiles];
  nativeCheckInputs = [git];

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    manPageDir=$(mktemp -d)
    $out/bin/tg man "$manPageDir"
    installManPage "$manPageDir"/*

    installShellCompletion --cmd tg \
      --bash <($out/bin/tg completion bash) \
      --fish <($out/bin/tg completion fish) \
      --zsh <($out/bin/tg completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    # keep-sorted start
    description = "Terminal client for Tangled";
    homepage = "https://tangled.org/secluded.site/tg";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tg";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
