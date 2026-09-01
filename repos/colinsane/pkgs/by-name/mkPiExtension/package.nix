{
  buildPackages,
  buildNpmPackage,
  lib,
  pi-coding-agent,
}:
lib.extendMkDerivation {
  constructDrv = buildNpmPackage;

  extendDrvArgs =
    finalAttrs:
    {
      postPatch ? "",
      postInstall ? "",
      ...
    }:
    {
      # N.B: postPatch, not patchPhase, otherwise it won't apply to npmDeps.
      postPatch = ''
        ${lib.getExe' buildPackages.nodejs "npm"} uninstall --offline --save-dev --package-lock-only @earendil-works/pi-coding-agent \
          --ignore-scripts $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
        ${postPatch}
      '';

      # link the pi-coding-agent dependency because it's frequently depended on by build scripts (e.g. tsc).
      # unless the caller has passed `dontNpmPrune`, it will only be available during build -- not in the installed modules.
      # preferably we would install this "properly", e.g.
      #
      # > npm install \
      # >   --no-save \
      # >   --bin-links=false \
      # >   "file:${pi-coding-agent}/lib/node_modules/pi-monorepo"
      #
      # -- but that produces relative symlinks, or --
      #
      # > npm install \
      # >   --install-links=true \
      # >   --no-save \
      # >   --bin-links=false \
      # >   "file:${pi-coding-agent}/lib/node_modules/pi-monorepo"
      #
      # -- but that copies the entire closure in and effects npmDepsHash (?)
      configurePhase = ''
        runHook preConfigure
        mkdir -p node_modules/@earendil-works
        ln -s "${pi-coding-agent}/lib/node_modules/pi-monorepo" node_modules/@earendil-works/pi-coding-agent
        runHook postConfigure
      '';

      # N.B.: postInstall, not installPhase so that npmInstallHook runs
      postInstall = ''
        packageName=$(${lib.getExe buildPackages.jq} --raw-output '.name' package.json)
        packagePath="$out/lib/node_modules/$packageName"

        # pi needs package.json to be at the root and does not handle symlinks correctly.
        # meanwhile, $out/bin/* wraps $out/lib/node_modules/$packageName/... so we have to keep those paths valid.
        # solution: lift $out/lib/node_modules/$packageName up to the root and replace the old path with a symlink to the new path.
        # N.B.: shopt -s dotglob so that we get the dotfiles too.
        (
          shopt -s dotglob
          mv "$packagePath"/* "$out/"
        )
        rmdir "$packagePath"
        ln -s $out "$packagePath"
        ${postInstall}
      '';
    };
  }
