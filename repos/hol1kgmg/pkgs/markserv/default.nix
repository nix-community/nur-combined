{
  lib,
  buildNpmPackage,
  fetchzip,
}:

buildNpmPackage rec {
  pname = "markserv";
  version = "1.21.1";

  # Upstream publishes no git tags, so the npm tarball is the source.
  src = fetchzip {
    url = "https://registry.npmjs.org/markserv/-/markserv-${version}.tgz";
    hash = "sha256-PtYI6Bhtj8+457wYYO/Df9HSMxHZPePgLsW7mqPMQbc=";
  };

  # ...and it ships no lockfile either.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-mR73l1TICJAJ90PLkrJYalROaD4qN2/DE7d2v4R5ClU=";

  dontNpmBuild = true;

  meta = {
    description = "Serve markdown as html (GitHub style), index directories, live-reload as you edit";
    homepage = "https://github.com/markserv/markserv";
    license = lib.licenses.mit;
    mainProgram = "markserv";
  };
}
