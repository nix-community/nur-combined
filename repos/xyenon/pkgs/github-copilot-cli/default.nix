{
  buildNpmPackage,
  fetchzip,
  lib,
}:

let
  pname = "github-copilot-cli";
  version = "0.1.36";
  baseUrl = "https://registry.npmjs.org/@githubnext/${pname}";
  pkgUrl = "${baseUrl}/-/${pname}-${version}.tgz";
in
buildNpmPackage {
  inherit pname version;

  src = fetchzip {
    url = pkgUrl;
    hash = "sha256-7n+7sN61OrqMVGaKll85+HwX7iGG9M/UW5lf2Pd5sRU=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-wtUvyPwDnCT2oIa/RZai9wLdgV1eHccwPUCKn9dvd78=";

  dontNpmBuild = true;

  passthru.updateScript = [
    ./updater.sh
    baseUrl
    pname
    version
  ];

  meta = with lib; {
    description = "A CLI experience for letting GitHub Copilot help you on the command line";
    homepage = "https://githubnext.com/projects/copilot-cli/";
    license = licenses.unfree;
    maintainers = with maintainers; [ xyenon ];
  };
}
