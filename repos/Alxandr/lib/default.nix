{
  pkgs,
  packages,
}:

let
  inherit (pkgs) lib;

in
rec {
  crate2nix =
    attrs@{
      # Package name
      pname,
      # Package meta
      meta,
      # Workspace source root (must match the workspace that generated the JSON)
      src,
      # Path to the pre-resolved JSON file
      resolvedJson,
      # Optional: function to create buildRustCrate for a given pkgs
      buildRustCrateForPkgs ? pkgs: pkgs.buildRustCrate,
      # Optional: default crate overrides
      defaultCrateOverrides ? pkgs.defaultCrateOverrides,
      # Optional: extra arguments to pass to the update script
      updateScriptExtraArgs ? [ ],
    }:
    let
      cargoNix = pkgs.callPackage ./crate2nix.nix {
        inherit
          src
          resolvedJson
          buildRustCrateForPkgs
          defaultCrateOverrides
          ;
      };
      pkg = cargoNix.workspaceMembers.${pname}.build;
    in
    pkg.overrideAttrs (
      finalAttrs: previousAttrs:
      let
        version = lib.strings.removePrefix "rust_${pname}-" previousAttrs.name;
      in
      {
        inherit pname version;
        name = "${pname}-${version}";
        meta = (previousAttrs.meta or { }) // meta;

        passthru = (previousAttrs.passthru or { }) // {
          updateSource = crate2nix-package-update-script.mkUpdateSource (
            attrs
            // {
              name = pname;
              version = finalAttrs.version;
            }
          );

          updateScript = crate2nix-package-update-script {
            extraArgs = [
              "--output"
              (toString resolvedJson)
            ]
            ++ updateScriptExtraArgs;
          };
        };

        __intentionallyOverridingVersion = true;
      }
    );

  mkAgentPlugins = pkgs.callPackage ./agent-plugins { inherit agentPluginsJoin; };
  agentPluginsJoin =
    fnOrAttrs:
    let
      flattenPlugins = lib.concatMap (
        plugin: if plugin.__isAgentPluginsJoin or false then flattenPlugins plugin.plugins else [ plugin ]
      );
    in
    pkgs.symlinkJoin (
      finalAttrs:
      let
        args = if lib.isFunction fnOrAttrs then fnOrAttrs (args' // finalAttrs) else fnOrAttrs;
        args' = args // {
          plugins = flattenPlugins args.plugins;
          paths = finalAttrs.plugins;
          passthru = (args.passthru or { }) // {
            pluginDir = "${finalAttrs.finalPackage}/share/agents/plugins";
            __isAgentPluginsJoin = true;
            filter =
              fn:
              finalAttrs.finalPackage.overrideAttrs (
                finalAttrs: prevAttrs: {
                  plugins = lib.filter fn prevAttrs.plugins;
                }
              );
          };
        };
      in
      args'
    );

  crate2nix-package-update-script = {
    __functor =
      self:
      {
        extraArgs ? [ ],
      }:
      [ (lib.getExe packages.update-crate2nix-package) ] ++ extraArgs;

    mkUpdateSource =
      attrs@{
        name,
        src,
        version,
        ...
      }:
      pkgs.stdenvNoCC.mkDerivation {
        pname = "${name}-src";
        inherit version src;

        dontUnpack = true;
        installPhase = "mkdir -p $out";
      }
      // attrs;
  };

  nuget-global-tool-update-script = {
    __functor =
      self:
      {
        extraArgs ? [ ],
      }:
      [ (lib.getExe packages.update-nuget-global-tool) ] ++ extraArgs;
  };
}
