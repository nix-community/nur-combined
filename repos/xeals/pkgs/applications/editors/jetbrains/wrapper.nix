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
  inherit plugins;
  # TODO: Remove version from directory name
  installPhase = oldAttrs.installPhase + ''
    for plugin in $plugins; do
      local dirname=$(basename "$plugin")
      dirname=''${dirname:33}
      ln -s "$plugin" "$out/$name/plugins/$dirname"
    done
  '';
}))
