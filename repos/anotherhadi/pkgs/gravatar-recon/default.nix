{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "gravatar-recon";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "gravatar-recon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pM9IvpzZVaQcX62r/oI6+LNT7cYP7WfnAcGGi27SY9w=";
  };

  vendorHash = "sha256-hjaIXZMK9+b+tlWD55OU3mS0CLUA/Oonn/RBHQdgs2g=";

  subPackages = ["cmd"];

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/gravatar-recon
  '';

  meta = {
    description = "Retrieves and aggregates public OSINT data from Gravatar for a target email: profile metadata, avatar, social accounts, and contact info";
    homepage = "https://github.com/anotherhadi/gravatar-recon";
    changelog = "https://github.com/anotherhadi/gravatar-recon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "gravatar-recon";
  };
})
