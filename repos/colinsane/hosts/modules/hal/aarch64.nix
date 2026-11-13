{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.aarch64;
in
{
  options = {
    sane.hal.aarch64.enable = (lib.mkEnableOption "aarch64-specific hardware support") // {
      default = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
    };
  };
  config = lib.mkIf cfg.enable {
    # disable the following non-essential programs which fail to cross compile
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2025-11-01 - 2026-09-02; blocked by ShellCheck, fgl)
    sane.programs.binwalk.enableFor = { system = false; user.colin = false; };  #< 2026-07-01 - 2026-11-11: blocked on sleuthkit
    sane.programs.cargo.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01 - 2026-09-02)
    sane.programs.ck.enableFor = { system = false; user.colin = false; };  #< 2026-07-01: blocked on openvino
    sane.programs.ctags-lsp.enableFor = { system = false; user.colin = false; };  #< universal-ctags does not cross compile (2026-02-26 - 2026-11-11)
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  #< does not cross compile
    sane.programs.git-cinnabar.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-06-10 - 2026-11-11)
    # sane.programs.git-lfs.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-06-26)
    sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2025-01-06 - 2026-09-02)
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: cross compiles, but the result is a x86 .NET exe (2025-01-05 - 2026-02-02)
    sane.programs.mercurial.enableFor.user.colin = false;  #< does not cross compile (2025-11-01 - 2026-11-11; unblocked)
    sane.programs.mesonlsp.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-02-26 - 2026-11-11; unblocked)
    # sane.programs.newsflash.enableFor.user.colin = false;  #< does not cross compile (2026-11-11; unblocked)
    # sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01 - 2026-02-02; unblocked)
    # sane.programs.nix-prefetch-git.enableFor = { system = false; user.colin = false; };  #< blocked on `git-lfs` (2026-06-05)
    sane.programs.resources.enableFor.user.colin = false;  #< does not cross compile (2025-11-01 - 2026-11-11; unblocked)
    sane.programs.rustc.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-05-31 - 2026-09-02)

    sane.programs.pi-coding-agent.config.coderag = false;  #< does not cross compile (2026-07-01)
    # sane.programs.pi-coding-agent.config.semble = false;  #< does not cross compile (2026-09-04)
    # sane.programs.pi-coding-agent.config.auto-zoekt = true;
  };
}
