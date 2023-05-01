{ buildNpmPackage, fetchzip, lib, ... }:

let
  pname = "github-copilot-cli";
  version = "0.1.33";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@githubnext/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-uTv6Z/AzvINinMiIfaaqRZDCmsAQ7tOE5SpuecpzGug=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-fry4q/oClTlrwpKGFEvu+mUncaw37azPNlsJxMPLW6w=";
  dontNpmBuild = true;

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
