{ minimal, ... }: {
  opts = {
    smartindent = true;
    # cindent = true;
    # cinkeys = "0{,0},0),0],:,!^F,o,O,e";
    expandtab = true;
    shiftwidth = 2;
    softtabstop = -1;
  };
  plugins = {
    fugitive.enable = true;
    vim-surround.enable = true;
    lsp = {
      enable = true;
      # for list of available servers see: (on the left side)
      # https://nix-community.github.io/nixvim/plugins/lsp/
      # or
      # https://nix-community.github.io/nixvim/${nixpkgs version}/plugins/lsp/
      servers = {
        # keep-sorted start block=yes
        bashls.enable = !minimal;
        html.enable = true;
        jsonls.enable = true;
        lua_ls.enable = !minimal;
        nixd.enable = !minimal;
        pyright.enable = !minimal;
        rust_analyzer = {
          enable = !minimal;
          installCargo = false;
          installRustc = false;
        };
        ts_ls.enable = !minimal;
        yamlls.enable = true;
        # keep-sorted end
      };
    };
    lean = {
      enable = false; # lean build is broken, previously !minimal;
      settings.mappings = true;
    };
  };
}
