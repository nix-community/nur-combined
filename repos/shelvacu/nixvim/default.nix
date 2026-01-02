{ minimal, ... }:
{
  opts = {
    cindent = true;
    cinkeys = "0{,0},0),0],:,!^F,o,O,e";
    expandtab = true;
    shiftwidth = 2;
    softtabstop = -1;
  };
  plugins = {
    vim-surround.enable = true;
    lsp = {
      enable = true;
      # for list of available servers see https://nix-community.github.io/nixvim/25.05/plugins/lsp/ on the left side
      servers = {
        # keep-sorted start block=yes
        bashls.enable = true;
        html.enable = true;
        jsonls.enable = true;
        lua_ls.enable = !minimal;
        nixd.enable = true;
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
