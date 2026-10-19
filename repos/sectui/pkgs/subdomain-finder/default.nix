{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_26,
}:
buildNpmPackage rec {
  pname = "subdomain-finder";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "subdomain-finder";
    rev = "v${version}";
    hash = "sha256-ETjjew7qSIKHucyZUrkAFFlNL8YRn6PN4s6qRpwxxGw=";
  };

  npmDepsHash = "sha256-3uJU3auZIUrPXpfmB4ClgbIjvK7aLxJsQR87sGAqY+g=";

  nodejs = nodejs_26;

  meta = with lib; {
    description = "Passive subdomain enumeration from public sources";
    homepage = "https://github.com/sectui/subdomain-finder";
    changelog = "https://github.com/sectui/subdomain-finder/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "subdomain-finder";
  };
}
