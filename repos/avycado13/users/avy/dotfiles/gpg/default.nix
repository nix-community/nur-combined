{ lib, config, ... }:
{
  options.dots.gpg.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the gpg dotfiles module.";
  };

  config = lib.mkIf config.dots.gpg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = true;
    };
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
