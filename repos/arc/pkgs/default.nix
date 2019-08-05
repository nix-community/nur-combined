{
  personal = import ./personal;
  public = import ./public;
  overrides = import ./overrides.nix;
  vimPlugins = import ./vimPlugins.nix;
  kakPlugins = import ./kakPlugins.nix;
  gitAndTools = import ./git;
  weechatScripts = import ./weechatScripts.nix;
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
