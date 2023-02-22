{ buildNpmPackage, fetchzip, lib, ... }:

let
  name = "github-copilot-cli";
  version = "0.1.16";
in
buildNpmPackage {
  pname = name;
  version = version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@githubnext/${name}/-/${name}-${version}.tgz";
    hash = "sha256-KNOKtNgm6hh7jcHIkZVQhQ3TvAcQYMnlwiA7oMPWlH4=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-PzeNwtQ5wZYTmInLNuLOcme4Cfzzzyd3psuGCrPzjQY=";
  dontNpmBuild = true;

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
