{ pkgs, ... }:
{
  sane.programs."gnome.nautilus" = {
    package = pkgs.gnome.nautilus.overrideAttrs (orig: {
      # enable the "Audio and Video Properties" pane. see: <https://nixos.wiki/wiki/Nautilus>
      buildInputs = orig.buildInputs ++ (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
      ]);
    });
  };
}
