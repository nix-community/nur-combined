{ buildNpmPackage, fetchzip, lib, ... }:

let
  pname = "github-copilot-cli";
  version = "0.1.21";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@githubnext/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-9FuNyUTIHBh3tPUd3ea7AXRZC+7inSv24o6VN4bvvvg=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-vlgiZxWCXzWTqDOcRxfhmd3BzVpiQ2+ivW6tt/DgWf4=";
  dontNpmBuild = true;

  meta = with lib;
    {
      description = "A CLI experience for letting GitHub Copilot help you on the command line";
      homepage = "https://githubnext.com/projects/copilot-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ xyenon ];
    };
}
