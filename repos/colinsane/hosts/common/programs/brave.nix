{ ... }:
{
  sane.programs.brave = {
    persist.cryptClearOnBoot = [
      ".cache/BraveSoftware"
      ".config/BraveSoftware"
    ];
  };
}
