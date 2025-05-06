{
  buildNpmPackage,
  src,
}:
buildNpmPackage {
  pname = "requestrr-webapp";
  version = "2.1.7-unstable-2025-02-21";

  inherit src;
  sourceRoot = "${src.name}/Requestrr.WebApi/ClientApp";

  npmDepsHash = "sha256-7uqK5xrG6z+K+GFB/V7xC3Apk8m/Kto9Z72Q7ZMDO64=";
  npmFlags = ["--legacy-peer-deps"];
  npmInstallFlags = ["--include=dev"];
  npmPruneFlags = ["--include=dev"];

  dontNpmBuild = true;
}
