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
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2025-11-01 - 2026-05-01; blocked by ShellCheck, fgl)
    sane.programs.binwalk.enableFor = { system = false; user.colin = false; };  #< 2026-07-01: blocked on sleuthkit
    sane.programs.cargo.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01 - 2026-02-02)
    sane.programs.ck.enableFor = { system = false; user.colin = false; };  #< 2026-07-01: blocked on openvino
    sane.programs.git-cinnabar.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-06-10)
    sane.programs.git-lfs.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-06-26)
    sane.programs.ctags-lsp.enableFor = { system = false; user.colin = false; };  #< universal-ctags does not cross compile (2026-02-26)
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  #< does not cross compile
    sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2025-01-06)
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: cross compiles, but the result is a x86 .NET exe (2025-01-05 - 2026-02-02)
    sane.programs.mercurial.enableFor.user.colin = false;  #< does not cross compile (2025-11-01 - 2026-05-23; unblocked)
    sane.programs.mesonlsp.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-02-26 - 2026-05-23)
    sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01 - 2026-02-02; unblocked)
    sane.programs.nix-prefetch-git.enableFor = { system = false; user.colin = false; };  #< blocked on `git-lfs` (2026-06-05)
    sane.programs.parallel.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-06-29)
    sane.programs.resources.enableFor.user.colin = false;  #< does not cross compile (2025-11-01 - 2026-05-23; unblocked)
    sane.programs.rustc.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2026-05-31)

    sane.programs.pi-coding-agent.config.coderag = false;  #< does not cross compile (2026-07-01)

    boot.kernelPatches = lib.mkIf (!(config.boot.kernelPackages.kernel.configfile.preferBuiltin or true)) [
      {
        # TODO: upstream into nixpkgs. <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/common-config.nix>
        name = "fix-module-builtin-mismatch";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          # nixpkgs specifies `SUN8I_DE2_CCU = yes`, but that in turn requires `SUNXI_CCU = yes` and NOT `= module`
          #   symptom: Kconfig build fails (2026-02-02)
          SUNXI_CCU = yes;
        };
      }
    ];
  };
}
