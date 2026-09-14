{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.herdr;
  activatePlugin =
    plugin:
    let
      id = plugin.meta.herdr.plugin.id;
    in
    ''
      ${lib.getBin cfg.package} plugin link "${plugin}/libexec/herdr/plugins/${id}/"
    '';
  activationScript = lib.concatStringsSep "\n" (lib.map activatePlugin cfg.plugins);

  isPluginAssertion = plugin: {
    assertion = plugin.meta.herdr.plugin.id or null != null;
    message = "Plugin package '${plugin.name}' is missing required 'meta.herdr.plugin.id'";
  };
in
{
  options = {
    programs.herdr = {
      installPlugins = lib.mkEnableOption "Enable the installation of Herdr plugins";
      plugins = lib.mkOption {
        description = "List of Herdr plugins to be installed";
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.installPlugins) {
    assertions = lib.map isPluginAssertion cfg.plugins;

    home.activation.herder-install-plugins = lib.hm.dag.entryAfter [
      "installPackages"
    ] activationScript;
  };
}
