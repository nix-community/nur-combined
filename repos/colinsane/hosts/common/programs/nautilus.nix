{ pkgs, ... }:
{
  sane.programs."gnome.nautilus" = {
    packageUnwrapped = pkgs.gnome.nautilus.overrideAttrs (orig: {
      # enable the "Audio and Video Properties" pane. see: <https://nixos.wiki/wiki/Nautilus>
      buildInputs = orig.buildInputs ++ (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
      ]);
    });

    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.whitelistDbus = [ "user" ];  # for portals launching apps
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      # grant access to pretty much everything, except for secret keys.
      # ".cache"
      # ".config"
      # ".local"
      "archive"
      "Books"
      "dev"
      "knowledge"
      "Music"
      "nixos"
      "Pictures"
      # "private"  #< explicitly NOT
      "records"
      "ref"
      "tmp"
      "use"
      "Videos"
    ];
    sandbox.extraPaths = [
      "boot"
      "mnt"
      # "nix"
      "tmp"
      "var"
    ];
    sandbox.extraRuntimePaths = [
      # not sure if these are actually necessary
      "gvfs"
      "gvfsd"
    ];

    mime.associations = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
}
