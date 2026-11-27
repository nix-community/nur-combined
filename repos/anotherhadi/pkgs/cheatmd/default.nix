{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:
buildGoModule rec {
  pname = "cheatmd";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "cheatmd-dev";
    repo = "cheatmd";
    rev = "v${version}";
    hash = "sha256-fZU70s6luiraNruW9EDFXQISPuoyCaZQ+kgmHUp8u5k=";
  };

  vendorHash = "sha256-ta5KLc8jILY92e8/JzTnW4V/F8eeZSGrobqw6pqMv90=";

  subPackages = ["cmd/cheatmd"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cheatmd \
      --bash <($out/bin/cheatmd completion bash) \
      --fish <($out/bin/cheatmd completion fish) \
      --zsh <($out/bin/cheatmd completion zsh)
  '';

  meta = with lib; {
    description = "Executable Markdown cheatsheets";
    homepage = "https://github.com/cheatmd-dev/cheatmd";
    changelog = "https://github.com/cheatmd-dev/cheatmd/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "cheatmd";
  };
}
