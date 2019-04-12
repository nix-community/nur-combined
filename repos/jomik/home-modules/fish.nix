{ config, lib, pkgs,... }:

with lib;
let
  cfg = config.programs.fish;

  fileType = textGen: types.submodule (
    { name, config, ... }: {
      options = {
        body = mkOption {
          default = null;
          type = types.nullOr types.lines;
          description = "Body of the file.";
        };

        source = mkOption {
          type = types.path;
          description = ''
            Path of the source file. The file name must not start
            with a period.
          '';
        };
      };

      config = {
        source = mkIf (config.body != null) (
          mkDefault (pkgs.writeTextFile {
            inherit name;
            text = textGen name config.body;
            executable = true;
          })
        );
      };
    }
  );
in {
  options = {
    programs.fish.plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        The plugins to add to fish.
        Built with <varname>buildFishPlugin</varname>.
        Overrides manually installed ones.
      '';
    };
    programs.fish.functions = mkOption {
      type = types.attrsOf (fileType (name: body: ''
            function ${name}
              ${body}
            end
            ''));
      default = {};
      description = ''
        Functions to add to fish.
      '';
    };
    programs.fish.completions = mkOption {
      type = types.attrsOf (fileType (name: body: body));
      default = {};
      description = ''
        Completions to add to fish.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      xdg.configFile = 
        (map (n: { target = "fish/functions/${n}.fish"; source = cfg.functions.${n}.source; }) (attrNames cfg.functions))
        ++ (map (n: { target = "fish/completions/${n}.fish"; source = cfg.completions.${n}.source; }) (attrNames cfg.completions));
    } (
    let
      wrappedPkgVersion = lib.getVersion pkgs.fish;
      wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" pkgs.fish.name;
      dependencies = concatMap (p: p.dependencies) cfg.plugins;
      combinedPluginDrv = pkgs.buildEnv {
        name = "${wrappedPkgName}-plugins-${wrappedPkgVersion}";
        paths = cfg.plugins;
        postBuild = ''
          touch $out/setup.fish

          if [ -d $out/functions ]; then
            echo "set fish_function_path \$fish_function_path[1] $out/functions \$fish_function_path[2..-1]" >> $out/setup.fish
          fi

          if [ -d $out/completions ]; then
            echo "set fish_complete_path \$fish_complete_path[1] $out/completions \$fish_complete_path[2..-1]" >> $out/setup.fish
          fi

          if [ -d $out/conf.d ]; then
            echo "source $out/conf.d/*.fish" >> $out/setup.fish
          fi
        '';
      };
    in mkIf (length cfg.plugins > 0) {
      xdg.configFile."fish/conf.d/99plugins.fish".source = "${combinedPluginDrv}/setup.fish";
      home.packages = dependencies;
    })
  ]);
}
