{
  inputs,
  pkgs,
  ...
}:

let
  inherit (inputs) dotfiles;

in
{
  imports = [
    "${inputs.self}/system/modules/personal"
    inputs.lix-module.nixosModules.default
  ];
  console.keyMap = "colemak";

  environment.systemPackages = with pkgs; [
    git
    vim
    p7zip
  ];

  nix.settings.trusted-users = [ "@nixers" ];

  security = {
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "nixers" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
    sudo.enable = false;
  };

  services.xserver.xkb.extraLayouts = {
    colemak-bs_cl = {
      description = "Colemak Layout with BackSpace and Caps Lock swapped";
      languages = [ "eng" ];
      symbolsFile = "${dotfiles}/config/xkbmap/colemak-bs_cl";
    };
    dvorak-bs_cl = {
      description = "Dvorak Layout with BackSpace and Caps Lock swapped";
      languages = [ "eng" ];
      symbolsFile = "${dotfiles}/config/xkbmap/dvorak-bs_cl";
    };
  };

  users = {
    mutableUsers = false;
    groups.nixers.name = "nixers";
  };
}
