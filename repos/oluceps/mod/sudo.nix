{
  flake.modules.nixos.sudo = {
    security = {
      sudo.extraConfig = ''
        Defaults lecture="never"
      '';

      doas = {
        enable = false;
        wheelNeedsPassword = false;
      };
      sudo-rs = {
        enable = false;
        extraRules = [
        ];
      };
    };
  };
}
