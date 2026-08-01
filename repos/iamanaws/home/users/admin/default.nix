{
  outputs,
  pkgs,
  ...
}:

let
  flakeOverlays = if outputs ? overlays then outputs.overlays else import ../../../overlays;
in
{
  # You can import other home-manager modules here
  imports = [ ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      flakeOverlays.additions
      flakeOverlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Add environment variables
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
