{ lib
}: self:

with lib;

package:
pluginsFun:

let
  plugins =
    if isFunction pluginsFun
    then pluginsFun self
    else pluginsFun;

  # FIXME: Is this still needed?
  info = builtins.parseDrvName package.name;
  badPlugins = filter (p: ! elem info.name p.jetbrainsPlatforms) plugins;
  errorMsg = "plugins [ ${toString (map (p: p.name) badPlugins)} ] are not available for platform ${info.name}";
in

assert assertMsg (length badPlugins == 0) errorMsg;

appendToName "with-plugins" (package.overrideAttrs (oldAttrs: {
  passthru = { inherit plugins; };
  # TODO: Purely aesthetics, but link the plugin to its name instead of hash-name-version
  installPhase = oldAttrs.installPhase + ''
    for plugin in $plugins; do
      ln -s "$plugin" "$out/$name/plugins/$(basename $plugin)"
    done
  '';
}))
