{ sources ? import ./nix/sources.nix
  # TODO: change to use stable nix and darwin channels once neovim 4 and coc-tsserver plugin are there.
 ,pkgs ? import sources.nixpkgs-unstable {} 
 ,neovim ? import sources.neovim-nix { lib = pkgs.lib; neovim = pkgs.neovim; }
}:

neovim.override {
  withNodeJs = true;
  configure = {
    customRC = ''
    "from customrc
    '';
    packages = {
      cocPlugins = with pkgs.vimPlugins; {
        start = [
          { 
            plugin = coc-nvim;
          }
          { 
            plugin = coc-tsserver; 
            settings = {
              "tsserver.log" = "verbose";
            };
          }
        ];
      };
    };
  };
}
  

