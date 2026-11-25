{
  lib,
  fetchzip,
  runCommand,
}:
{
  fetchGitHubArchive =
    source:
    fetchzip {
      inherit (source) url hash;
      extension = "tar.gz";
    };

  mkPluginSet =
    {
      catalog,
      manifestPath,
      filter ? (_: _: true),
      buildPlugin,
    }:
    let
      manifest = builtins.fromJSON (builtins.readFile manifestPath);
    in
    lib.recurseIntoAttrs (
      lib.mapAttrs (
        name: plugin:
        buildPlugin {
          inherit name plugin;
          source = manifest.${name};
        }
      ) (lib.filterAttrs filter catalog)
    );

  mkPluginCollection =
    {
      name,
      plugins,
      extraLinks ? { },
      extraCheck ? "",
    }:
    let
      pluginDerivations = lib.filterAttrs (_: lib.isDerivation) plugins;
      names = builtins.attrNames pluginDerivations;
    in
    runCommand name { } ''
      mkdir -p "$out"

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (linkName: target: ''
          mkdir -p "$out/${builtins.dirOf linkName}"
          ln -s ${target} "$out/${linkName}"
        '') extraLinks
      )}

      ${lib.concatMapStringsSep "\n" (pluginName: ''
        mkdir -p "$out/${builtins.dirOf pluginName}"
        ln -s ${pluginDerivations.${pluginName}} "$out/${pluginName}"
      '') names}

      ${extraCheck}
    '';
}
