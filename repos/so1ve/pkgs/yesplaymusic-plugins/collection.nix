{
  callPackage,
  jq,
  lib,
  stdenv,
  yesplaymusic,
}:

let
  pluginLib = callPackage ../../lib/plugins.nix { };
  plugins = lib.filterAttrs (_: lib.isDerivation) (callPackage ./. { });
  canCheckApp = lib.meta.availableOn stdenv.hostPlatform yesplaymusic;
  appWithPlugins = yesplaymusic.withPlugins (_: builtins.attrValues plugins);
in
pluginLib.mkPluginCollection {
  name = "yesplaymusic-plugins";
  inherit plugins;
  extraLinks = lib.optionalAttrs canCheckApp {
    yesplaymusic-with-plugins = appWithPlugins;
  };
  extraCheck = ''
    ${lib.concatMapStringsSep "\n" (name: ''
      min_app="$(${lib.getExe jq} -r '.minAppVersion // empty' "${plugins.${name}}/plugin.json")"
      if [[ -n "$min_app" ]]; then
        lowest="$(printf '%s\n%s\n' "$min_app" ${lib.escapeShellArg yesplaymusic.version} | sort -V | head -n 1)"
        if [[ "$lowest" != "$min_app" ]]; then
          echo "${name}: requires YesPlayMusic >= $min_app, packaged version is ${yesplaymusic.version}" >&2
          exit 1
        fi
      fi
    '') (builtins.attrNames plugins)}
  '';
}
