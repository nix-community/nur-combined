{
  personal = import ./personal;
  public = import ./public;
  overrides = import ./overrides.nix;
  vimPlugins = import ./vimPlugins.nix;
  kakPlugins = import ./kakPlugins.nix;
  rxvt-unicode-plugins = import ./urxvt;
  gitAndTools = import ./git;
  weechatScripts = import ./public/weechat/scripts.nix;
  shells = import ../shells;
}
  /*select = {
    all = personal // public;
    derivations = personal // public // vimPlugins // kakPlugins // gitAndTools // overrides.overrides;
    overrides = overrides.overrides // {
      inherit (overrides) override;
    };
    inherit personal public vimPlugins kakPlugins gitAndTools;
  };
  packages = {
    inherit select;
  } // select.all;*/
