{ buildNpmPackage, fetchzip, lib }:

let
  pname = "github-copilot-cli";
  version = "0.1.33";
  baseUrl = "https://registry.npmjs.org/@githubnext/${pname}";
  pkgUrl = "${baseUrl}/-/${pname}-${version}.tgz";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = pkgUrl;
    hash = "sha256-uTv6Z/AzvINinMiIfaaqRZDCmsAQ7tOE5SpuecpzGug=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-fry4q/oClTlrwpKGFEvu+mUncaw37azPNlsJxMPLW6w=";

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
