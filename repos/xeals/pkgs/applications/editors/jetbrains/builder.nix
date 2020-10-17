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

  info = builtins.parseDrvName package.name;

  badPlugins = filter (p: ! elem info.name p.jetbrainsPlatforms) plugins;
  errorMsg = "plugins [ ${toString (map (p: p.name) badPlugins)} ] are not available for platform ${info.name}";
in

assert assertMsg (length badPlugins == 0) errorMsg;

package.overrideAttrs (oldAttrs: {
  # FIXME: versioning: could just expose upstream
  name = "${info.name}-with-plugins-${info.version}";

  inherit plugins;
  installPhase = oldAttrs.installPhase + ''
    for plugin in $plugins; do
      ln -s "$plugin" "$out/$name/plugins/$(basename $plugin)"
    done
  '';
})
