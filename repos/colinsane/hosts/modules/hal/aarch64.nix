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
    sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2025-11-01; blocked by ShellCheck)
    sane.programs.cargo.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01)
    # sane.programs.fcitx5.enableFor.user.colin = false;  #< does not cross compile (2025-01-05; blocked by qtsvg)
    sane.programs.firefox.config.addons.browserpass-extension.enable = false;  #< does not cross compile
    sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2025-01-06)
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: cross compiles, but the result is a x86 .NET exe (2025-01-05)
    sane.programs.mercurial.enableFor.user.colin = false;  #< does not cross compile (2025-11-01; unblocked)
    sane.programs.nix-tree.enableFor = { system = false; user.colin = false; };  #< does not cross compile (2025-11-01; unblocked)
    # sane.programs.pyright.enableFor = { system = false; user.colin = false; };  #< python neovim LSP: doesn't cross compile (2025-11-01; unblocked)
    sane.programs.resources.enableFor.user.colin = false;  #< does not cross compile (2025-11-01; unblocked)
    # sane.programs.typescript-language-server.enableFor = { system = false; user.colin = false; };  #< doesn't cross compile (2025-07-18; via `moreutils`)

    boot.kernelPatches = lib.optionals (!pkgs.stdenv.hostPlatform.linux-kernel.preferBuiltin) [
      {
        # TODO: upstream into nixpkgs. <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/common-config.nix>
        name = "fix-module-builtin-mismatch";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          # nixpkgs specifies `SUN8I_DE2_CCU = yes`, but that in turn requires `SUNXI_CCU = yes` and NOT `= module`
          #   symptom: Kconfig build fails
          SUNXI_CCU = yes;
        };
      }
    ];
  };
}
