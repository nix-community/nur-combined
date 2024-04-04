_: {

  programs =
    let
      commandLineArgs = [
        "--enable-wayland-ime"
        "--ozone-platform=wayland"
        "--gtk-version=4"
      ];
    in
    # let commandLineArgs = [ "--gtk-version=4" "--ozone-platform=wayland" "--disable-features=WaylandFractionalScaleV1" ];
    {
      chromium = {
        enable = true;
        inherit commandLineArgs;
      };
      google-chrome = {
        enable = true;
        inherit commandLineArgs;
      };

      brave = {
        enable = true;
        inherit commandLineArgs;
      };
    };
}
