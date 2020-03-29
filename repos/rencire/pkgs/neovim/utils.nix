{ lib }:
{
  # This util function is responsible for:
  # 1. Combining `vimrc` String from each plugin into one String.
  # 2. Combining coc `settings` from each plugin, and converting result into a vimscript String.
  #    Note: this function assumes a plugin attribute set w/ `settings` key is a coc plugin.
  #    See https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file.
  #
  # plugins:  List
  # customRC: String
  combineVimRC = plugins: customRC:
    let
      pluginsVimrc =  
        (builtins.map 
          # TODO use `attrByPath` to avoid using filter ("" as default value if "vimrc" doesn't exist)
          (x: x.vimrc) 
          (builtins.filter 
            (x: x ? "vimrc")
            plugins) 
        );

      cocPluginsSettings =
        (builtins.map
	  (x: lib.attrsets.attrByPath ["settings"] {} x)  # default to empty set if "settings" doesn't exist
	  (builtins.filter
	    (p: builtins.hasAttr "plugin" p && lib.strings.hasPrefix "vimplugin-coc-" p.plugin.name) 
	    plugins)
        );

      cocSettingsJSONString = builtins.toJSON (builtins.foldl' (x: y: x // y) {} cocPluginsSettings);

      cocUserConfig = ''
          " Generated coc settings config
          let g:coc_user_config = json_decode('${cocSettingsJSONString}')
        '';
    in
      builtins.concatStringsSep 
        "\n"
        ( [ customRC cocUserConfig ] ++ pluginsVimrc )
    ;
}
