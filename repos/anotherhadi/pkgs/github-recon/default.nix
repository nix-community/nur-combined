{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "github-recon";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "github-recon";
    rev = "v${version}";
    hash = "sha256-5kbHFRfJpUk8qnfPxy6Ca65DtYOuI6Z8nwZiUWEK5dM=";
  };

  vendorHash = "sha256-AD0h0k2n8gPqSBz5qqb0ZON/jWiSEWpeO97xR7cYSy8=";

  subPackages = ["cmd"];

  ldflags = ["-s" "-w"];

  postInstall = ''
    mv $out/bin/cmd $out/bin/github-recon
  '';

  meta = with lib; {
    description = "Retrieves and aggregates public OSINT data about a GitHub user using Go and the GitHub API. Finds hidden emails in commit history, previous usernames, friends, other GitHub accounts, and more.";
    homepage = "https://github.com/anotherhadi/github-recon";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "github-recon";
  };
}
