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
  owner ? "duckdb",
  fetchSubmodules ? false,
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
        owner
        repo
        rev
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
  };

  meta = {
    description = "DuckDB ${name} extension source";
    homepage = "https://github.com/${owner}/${repo}";
    platforms = lib.platforms.all;
  };
}
