{ buildNpmPackage, fetchzip, lib, ... }:

let
  pname = "github-copilot-cli";
  version = "0.1.30";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@githubnext/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-a3w1cxyhvkzb4pifdoms49DuVpGyop/2GlSsVZRfeHY=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-LrEMM+ZykSP2lCOA13TPrAY9S2Z/wJ4Kavosf88iuzc=";
  dontNpmBuild = true;

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
