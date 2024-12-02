{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.aarch64;
in
{
  options = {
    sane.hal.aarch64.enable = (lib.mkEnableOption "aarch64-specific hardware support") // {
      default = pkgs.system == "aarch64-linux";
    };
  };
  config = lib.mkIf cfg.enable {

    # swap papers for zathura, since only one of these cross-compiles (TODO: enable cross compilation of papers!)
    sane.programs.guiBaseApps.suggestedPrograms = [ "zathura" ];
    sane.programs.papers.enableFor.user.colin = false;

    # disable the following non-essential programs which fail to cross compile
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile
    sane.programs.fcitx5.enableFor.user.colin = false;
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  #< does not cross compile
    sane.programs.ltex-ls.enableFor = { system = false; user.colin = false; };  # LaTeX/html/markdown neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.mercurial.enableFor.user.colin = false;
    sane.programs.nvme-cli.enableFor.system = false;  # does not cross compile (libhugetlbfs)
    sane.programs.pyright.enableFor = { system = false; user.colin = false; };  # python neovim LSP: doesn't cross compile (2024-08-26)

    # disable the following non-essential programs which are excessively slow to build or large to copy
    sane.programs.rust-analyzer.enableFor = { system = false; user.colin = false; };  # rust neovim LSP
    sane.programs.typescript-language-server.enableFor = { system = false; user.colin = false; };  # rust js/TypeScript LSP
  };
}
