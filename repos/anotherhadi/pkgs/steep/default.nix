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
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "steep";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mwoXurOv1iQ8lpRvjTUDcrWaHODIHORTMC38pdrp/IQ=";
  };

  vendorHash = "sha256-RDGCWH8QwLk0wiUVtC58Lu6TK/ZCB4p/8JK/yg4KzkI=";

  subPackages = ["cmd/steep"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anotherhadi/steep/internal/config.Version=${finalAttrs.version}"
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
    homepage = "https://github.com/anotherhadi/steep";
    changelog = "https://github.com/anotherhadi/steep/releases/tag/v${finalAttrs.version}";
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
