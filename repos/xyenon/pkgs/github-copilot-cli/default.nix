{ buildNpmPackage, fetchzip, lib, ... }:

let
  pname = "github-copilot-cli";
  version = "0.1.20";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@githubnext/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-GO/zpcYNSPPq0KlUXmTyu23mM1ujZBsu21IEKiYYh4k=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-hquIWYM0vUvXJE4Tf9sH7McGfg5vNkZLFrvEhsMGlGE=";
  dontNpmBuild = true;

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
