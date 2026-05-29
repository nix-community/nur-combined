# Fetch and build a pi package from npm registry using buildNpmPackage
# Requires pre-generated package-lock.json and npmDepsHash
# Use ./scripts/generate-hashes.sh to generate these
{ pkgs, lib }:

let
  # Load pre-computed hashes and lock file paths
  npmDepsHashes = import ../scripts/npm-deps-hashes.nix;
in

{ name
, version
, hash
, scope ? ""
,
}:
let
  fullName = if scope != "" then "${scope}/${name}" else name;
  tarballUrl = "https://registry.npmjs.org/${fullName}/-/${name}-${version}.tgz";
  pname = lib.replaceStrings [ "@" "/" ] [ "-at-" "-" ] fullName;

  # Look up pre-computed deps info
  depsInfo = npmDepsHashes.${fullName} or (throw "No npmDepsHash found for ${fullName}. Run scripts/generate-hashes.sh first.");
in
pkgs.buildNpmPackage {
  inherit pname version;

  src = pkgs.fetchurl {
    url = tarballUrl;
    inherit hash;
  };

  # Copy pre-generated package-lock.json into the source
  postPatch = ''
    cp ${depsInfo.lockFile} package-lock.json
  '';

  # Use pre-computed hash for npm dependencies
  npmDepsHash = depsInfo.npmDepsHash;

  # These are pre-built packages, no build step needed
  dontNpmBuild = true;

  # Some packages have no deps
  forceEmptyCache = depsInfo.forceEmptyCache or false;

  # Don't run npm install scripts (security)
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Pi package: ${fullName} v${version}";
    homepage = "https://www.npmjs.com/package/${fullName}";
  };
}
