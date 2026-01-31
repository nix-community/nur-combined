{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "changesets-cli";
  version = "2.29.7";

  src = fetchurl {
    url = "https://registry.npmjs.org/@changesets/cli/-/cli-${version}.tgz";
    hash = "sha256-Qey9NkqwwGEds/dL14YpZV+u4ZTD0gD2M3Yudn3Yla4=";
  };

  npmDepsHash = "sha256-WDdUewKCs6xp//RVm3J9f46u4E1yaj7MxIpi7XPx0S8=";

  npmFlags = [ "--legacy-peer-deps" ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "A way to manage your versioning and changelogs with a focus on monorepos";
    homepage = "https://github.com/changesets/changesets";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "changeset";
  };
}
