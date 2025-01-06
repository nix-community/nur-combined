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
    sane.programs.papers.enableFor.user.colin = false;  #< does not cross compile (2025-01-05; unblocked)

    # disable the following non-essential programs which fail to cross compile
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2025-01-05; blocked by ShellCheck)
    sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile (2025-01-05; blocked by marco)
    sane.programs.fcitx5.enableFor.user.colin = false;  #< does not cross compile (2025-01-05; blocked by qtsvg)
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  #< does not cross compile
    # sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: cross compiles, but the result is a x86 .NET exe (2025-01-05)
    sane.programs.mercurial.enableFor.user.colin = false;  #< does not cross compile (2025-01-05; unblocked)
    sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-01-05; blocked by vty)
    sane.programs.pyright.enableFor = { system = false; user.colin = false; };  # python neovim LSP: doesn't cross compile (2025-01-05; unblocked)
  };
}
