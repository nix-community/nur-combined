{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "commit-and-tag-version";
  version = "12.0.0";

  src = fetchFromGitHub {
    owner = "absolute-version";
    repo = "commit-and-tag-version";
    rev = "v${version}";
    hash = "sha256-vKoyBuXF/Rhvg/pCopP5DxsddUCUXbyQAkwsDhVUHjE=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-WlJ9ZMUsrhP7K6mJDXJvkaCSS3rHN4nNb0SOwpCtXlk=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "A utility for versioning using semver and CHANGELOG generation powered by Conventional Commits";
    homepage = "https://github.com/absolute-version/commit-and-tag-version";
    license = licenses.isc;
  };
}
