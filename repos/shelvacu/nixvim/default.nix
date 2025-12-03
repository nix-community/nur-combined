{
  config,
  lib,
  minimal,
  ...
}:
{
  opts = {
    smartindent = true;
    expandtab = true;
    shiftwidth = 2;
    softtabstop = -1;
  };
  plugins.comment.enable = true;
  plugins.vim-surround.enable = true;
  plugins.lsp = {
    enable = true;
    # for list of available servers see https://nix-community.github.io/nixvim/25.05/plugins/lsp/ on the left side
    servers = {
      bashls.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = !minimal;
      nixd = {
        enable = true;
        cmd = [
          (lib.getExe config.plugins.lsp.servers.nixd.package)
          "--log=error"
        ];
      };
      pyright.enable = !minimal;
      rust_analyzer = {
        enable = !minimal;
        installCargo = false;
        installRustc = false;
      };
      ts_ls.enable = !minimal;
      yamlls.enable = true;
    };
  };
  plugins.lean.enable = false; # lean build is broken, previously !minimal;
  plugins.lean.settings.mappings = true;
}
