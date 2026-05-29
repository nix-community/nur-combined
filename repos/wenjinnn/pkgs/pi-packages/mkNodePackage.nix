# mkNodePackage - Helper to create node packages with dependencies
# Uses buildNpmPackage to properly install dependencies
{ pkgs, lib }:

{
  # Package name (without scope)
  name,
  # Package version
  version,
  # npm scope (e.g., "@gotgenes")
  scope ? "",
  # SHA256 hash of the tarball
  hash,
  # npmDepsHash for dependency resolution
  npmDepsHash,
  # Vendored package-lock.json (optional)
  packageLockJson ? null,
  # Meta information
  description ? "",
  homepage ? "",
  license ? null,
  ...
}:
let
  fullName = if scope != "" then "${scope}/${name}" else name;
  pname = lib.replaceStrings [ "@" "/" ] [ "-at-" "-" ] fullName;
  tarballUrl = "https://registry.npmjs.org/${fullName}/-/${name}-${version}.tgz";
  hasDeps = npmDepsHash != "" && npmDepsHash != "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
in
if hasDeps then
  pkgs.buildNpmPackage {
    inherit pname version npmDepsHash;

    src = pkgs.fetchurl {
      url = tarballUrl;
      inherit hash;
    };

    # Copy vendored package-lock.json and clean package.json
    postPatch = ''
      # Copy lock file if provided
      ${lib.optionalString (packageLockJson != null) "cp ${packageLockJson} package-lock.json"}
      
      # Remove devDependencies and peerDependencies to avoid installing them
      if [ -f package.json ]; then
        ${pkgs.nodejs}/bin/node -e "
          const fs = require('fs');
          const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
          delete pkg.devDependencies;
          delete pkg.peerDependencies;
          delete pkg.peerDependenciesMeta;
          fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
      fi
    '';

    # Don't run build scripts for extensions
    dontNpmBuild = true;

    # Install to root of $out (pi expects package files at root)
    installPhase = ''
      runHook preInstall

      # Copy all files to root of $out
      cp -r . $out/

      runHook postInstall
    '';

    meta = with lib; {
      inherit description homepage;
      license = if license != null then license else licenses.mit;
      platforms = platforms.all;
    };
  }
else
  # For packages with no dependencies, just extract the tarball
  pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = tarballUrl;
      inherit hash;
    };

    dontBuild = true;
    dontConfigure = true;

    # Extract directly to $out (pi expects package files at root)
    unpackPhase = ''
      runHook preUnpack
      mkdir -p $out
      tar xzf $src -C $out --strip-components=1
      cd $out
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      # Already installed to $out in unpackPhase
      runHook postInstall
    '';

    meta = with lib; {
      inherit description homepage;
      license = if license != null then license else licenses.mit;
      platforms = platforms.all;
    };
  }
