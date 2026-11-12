{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "github-recon";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "github-recon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JsipG+DHH9ZgptI16fCizXkXCJOfhI/2dwp91almpS8=";
  };

  vendorHash = "sha256-8gpqIpX44oLO3Mxmn2Suy7t8trShTDG5U4Edl7byvrY=";

  subPackages = ["cmd"];

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/github-recon
  '';

  meta = {
    description = "Retrieves and aggregates public OSINT data about a GitHub user: hidden commit emails, previous usernames, linked accounts, and more";
    homepage = "https://github.com/anotherhadi/github-recon";
    changelog = "https://github.com/anotherhadi/github-recon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "github-recon";
  };
})
