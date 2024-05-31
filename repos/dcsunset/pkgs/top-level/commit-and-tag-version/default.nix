{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "commit-and-tag-version";
  version = "12.4.1";

  src = fetchFromGitHub {
    owner = "absolute-version";
    repo = "commit-and-tag-version";
    rev = "v${version}";
    hash = "sha256-OknqBEAA0Bv4Vz3XzQ64pHsw5pctwaZFkrUUfQ+21O8=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-FiLgiFiu14ADIJIaikIj+9/sPR0KuyYojhEAC0yJWVI=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "A utility for versioning using semver and CHANGELOG generation powered by Conventional Commits";
    homepage = "https://github.com/absolute-version/commit-and-tag-version";
    license = licenses.isc;
  };
}
