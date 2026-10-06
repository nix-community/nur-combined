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
  loadableTarget ? "${name}_loadable_extension",
  # C API extensions can only be loaded at runtime
  linkable ? true,
  # other extensions (by attribute name) this extension loads
  dependencies ? [ ],
  duckdbBuildInputs ? [ ],
  duckdbNativeBuildInputs ? [ ],
  # pkg-config modules whose libraries programs linking the extension statically also need
  pkgConfigModules ? [ ],
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
        loadableTarget
        linkable
        dependencies
        duckdbBuildInputs
        duckdbNativeBuildInputs
        pkgConfigModules
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
    ]
    ++ (
      if submodulePath == null then
        [ "--no-submodule" ]
      else
        [
          "--submodule-path"
          submodulePath
        ]
    )
    ++ [
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
