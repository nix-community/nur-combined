{ buildNpmPackage, fetchzip, lib }:

let
  pname = "github-copilot-cli";
  version = "0.1.35";
  baseUrl = "https://registry.npmjs.org/@githubnext/${pname}";
  pkgUrl = "${baseUrl}/-/${pname}-${version}.tgz";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = pkgUrl;
    hash = "sha256-mG05ppDSwtJi/Fk1s98M2KsKiEFW67cPpSgvMRos0lg=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-LX3ix2iF9nSRg18NAxSaCmJXIZs9o/CPQg68oZKU4r0=";

  dontNpmBuild = true;

  passthru.updateScript = [ ./updater.sh baseUrl pname version ];

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
