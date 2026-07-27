{ pkgs, ... }:

{
  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp exts.pass-genphrase exts.pass-update ]);
  };
  home.packages = with pkgs; [
    wofi-pass
  ];
}
