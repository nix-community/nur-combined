{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "commit-and-tag-version";
  version = "11.3.0";

  src = fetchFromGitHub {
    owner = "absolute-version";
    repo = "commit-and-tag-version";
    rev = "v${version}";
    hash = "sha256-XKHuxOQveUwnvW7sB6tRCSbHGrWqbNYmZiRqNYkTj48=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-dzEuDqIfu/WFbA2RVcrjJV8QQnFjRWRruls1t9R/VhM=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "A utility for versioning using semver and CHANGELOG generation powered by Conventional Commits";
    homepage = "https://github.com/absolute-version/commit-and-tag-version";
    license = licenses.isc;
  };
}
