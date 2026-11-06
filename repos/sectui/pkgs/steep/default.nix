{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  fzf,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "steep";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "steep";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/ii1BKond8ue+4Acakl8HqipUDC4NpHx9YmKhklM4po=";
  };

  vendorHash = "sha256-ngD9hf4zS+QKPxb/aI+bVgmM06b2N2wc/0drPvP9HfA=";

  subPackages = ["cmd/steep"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sectui/steep/internal/config.Version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [makeWrapper];

  # fzf is the default wordlist picker (filePicker in the config).
  postInstall = ''
    wrapProgram $out/bin/steep --suffix PATH : ${lib.makeBinPath [fzf]}
  '';

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/steep";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI to edit, replay and fuzz raw HTTP requests, powered by ffuf";
    homepage = "https://github.com/sectui/steep";
    changelog = "https://github.com/sectui/steep/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "steep";
  };
})
