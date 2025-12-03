{ config, lib, ... }:
let
  cfg = config.sane.hal.samsung;
in
{
  config = lib.mkIf cfg.enable {

    # disable the following non-essential programs which fail to cross compile
    sane.programs."sane-scripts.bt-search".enableFor.user.colin = false;  # 2024/06/03: does not cross compile
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile
    sane.programs.efibootmgr.enableFor = { system = false; user.colin = false; };  # efivar doesn't cross compile (2024-09-14)
    sane.programs.fcitx5.enableFor.user.colin = false;
    sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2025-01-06)
    sane.programs.ltex-ls.enableFor = { system = false; user.colin = false; };  # LaTeX/html/markdown neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.mepo.enableFor.user.colin = false;  # 2024/06/04: doesn't cross compile (nodejs)
    sane.programs.mercurial.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
    sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-01-05; blocked by vty)
    sane.programs.nixpkgs-review.enableFor.user.colin = false;  # 2024/06/03: OOMs when cross compiling
    sane.programs.ntfy-sh.enableFor.user.colin = false;  # 2024/06/04: doesn't cross compile (nodejs)
    sane.programs.nvme-cli.enableFor.system = false;  # does not cross compile (libhugetlbfs)
    sane.programs.papers.enableFor.user.colin = false;
    sane.programs.pwvucontrol.enableFor.user.colin = false;  # 2024/06/03: doesn't cross compile (libspa-sys)
    sane.programs.pyright.enableFor = { system = false; user.colin = false; };  # python neovim LSP: doesn't cross compile (2024-08-26)
    sane.programs.sequoia-sq.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
    sane.programs.zathura.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
    # sane.programs.brave.enableFor.user.colin = false;  # 2024/06/03: fails eval if enabled on cross
    # sane.programs.firefox.enableFor.user.colin = false;  # 2024/06/03: this triggers an eval error in yarn stuff -- i'm doing IFD somewhere!!?

    # disable the following non-essential programs which are excessively slow to build or large to copy
    sane.programs.rust-analyzer.enableFor = { system = false; user.colin = false; };  # rust neovim LSP
    sane.programs.typescript-language-server.enableFor = { system = false; user.colin = false; };  # rust js/TypeScript LSP
  };
}
