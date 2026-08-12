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
buildGo126Module {
  pname = "tg";
  version = "0-unstable-2026-07-31";

  src = fetchgit {
    url = "https://tangled.org/aly.codes/tg";
    rev = "c2391cb2f22526bcb0beb1b84c7764084436f9e7";
    hash = "sha256-0R6k6X7/k2/LjAy/pwPke/ja/Lx9/MFrF/jYtAKIdqI=";
  };

  vendorHash = "sha256-NXjakn2F/FC+KiaoNs7kei1dELKyy5FqSAlo/MxbtaM=";
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
    description = "Command-line client for Tangled";
    homepage = "https://tangled.org/aly.codes/tg";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tg";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
