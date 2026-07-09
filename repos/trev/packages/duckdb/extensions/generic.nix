{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

{
  name,
  repo,
  rev,
  hash,
  attrName ? lib.replaceStrings [ "_" ] [ "-" ] name,
  branch,
  owner ? "duckdb",
  fetchSubmodules ? false,
  submodulePath ? "duckdb",
  loadOptions ? [ ],
  duckdbBuildInputs ? [ ],
  duckdbPostPatch ? "",
}:

stdenvNoCC.mkDerivation {
  pname = "duckdb-extension-${name}";
  version = builtins.substring 0 12 rev;

  src = fetchFromGitHub (
    {
      inherit
        owner
        repo
        rev
        hash
        ;
    }
    // lib.optionalAttrs fetchSubmodules {
      fetchSubmodules = true;
    }
  );

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R ./. "$out/"
    chmod -R u+w "$out"

    runHook postInstall
  '';

  passthru = {
    duckdbExtension = {
      inherit
        name
        loadOptions
        duckdbBuildInputs
        duckdbPostPatch
        ;
    };

    updateScript = [
      "bash"
      "packages/duckdb/extensions/update.sh"
      "--owner"
      owner
      "--repo"
      repo
      "--branch"
      branch
      "--submodule-path"
      submodulePath
      "--override-filename"
      "packages/duckdb/extensions/${attrName}.nix"
      "--attr"
      "duckdb.extensions.${attrName}"
    ];
  };

  meta = {
    description = "DuckDB ${name} extension source";
    homepage = "https://github.com/${owner}/${repo}";
    platforms = lib.platforms.all;
  };
}
