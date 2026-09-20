{
  lib,
  buildNpmPackage,
  fetchzip,
}:

buildNpmPackage rec {
  pname = "markserv";
  version = "1.17.4";

  # Upstream publishes no git tags, so the npm tarball is the source.
  src = fetchzip {
    url = "https://registry.npmjs.org/markserv/-/markserv-${version}.tgz";
    hash = "sha256-mbYwuyTKmtgxceyBBY0iBDn0B75yex1E6mbsCxOjA1Q=";
  };

  # ...and it ships no lockfile either.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-A7xJPnCYow06rsZ42/16etfGEuM0/auvOwpw/z1AQK4=";

  dontNpmBuild = true;

  meta = {
    description = "Serve markdown as html (GitHub style), index directories, live-reload as you edit";
    homepage = "https://github.com/markserv/markserv";
    license = lib.licenses.mit;
    mainProgram = "markserv";
  };
}
