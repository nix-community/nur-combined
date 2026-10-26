{
  flake.modules.nixos = {
    base-pkgs =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.steelix ];
      };

    home =
      { config, pkgs, ... }:
      let
        plugin = pkgs.helix-fcitx-focus;
      in
      {
        hjem.users.${config.identity.user} = {
          xdg.config.files."helix/helix-fcitx-focus".source = "${plugin}/share/steel/cogs/helix-fcitx-focus";
          xdg.data.files."steel/native/libhelix_fcitx_focus.so".source =
            "${plugin}/lib/libhelix_fcitx_focus.so";
        };
      };
  };
}
