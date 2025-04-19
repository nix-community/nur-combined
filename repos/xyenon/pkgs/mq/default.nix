{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.1.1-unstable-2025-04-18";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "0a44c75900f826ab13ff3d25f77bfba0c9263460";
    hash = "sha256-s6hjmhLbsAAkMuybTsrMaoNCWhArT+deRZUlv/ZjVMA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-wNU/sTs6riymdqj9ENJtfNi+xhzegeifs6ML6UiTGow=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mq \
      --bash <($out/bin/mq completion --shell bash) \
      --fish <($out/bin/mq completion --shell fish) \
      --zsh <($out/bin/mq completion --shell zsh)
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
