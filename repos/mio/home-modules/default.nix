rec {
  # Add your Home Manager modules here
  default = (
    { ... }:
    {
      imports = [
        miodroid
        toshy
      ];
    }
  );
  miodroid = ./miodroid.nix;
  toshy = ../by-name/to/toshy/hm-module.nix;
}
