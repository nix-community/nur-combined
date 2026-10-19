{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dots.browser.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the browser dotfiles module.";
  };

  config = lib.mkIf config.dots.browser.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.nur.forkprince.helium-nightly;
    };
  };
}
