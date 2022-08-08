{
  pkgs,
  lib,
}: let
  # Build the virt-manager 2.2.1 package from the old Nix expression, but using
  # the current libraries (this works much better than trying to use the
  # package from an old nixpkgs snapshot, because that old package would use
  # the old version of `gdk-pixbuf`, which is not compatible with the global
  # state from the current nixpkgs, like the `$GDK_PIXBUF_MODULE_FILE`
  # environment variable).
  #
  # `./virt-manager-2.2.1.nix` is originally from the virt-manager 2.2.1 Nix
  # expression taken from an old nixpkgs revision (but also includes further
  # modifications to get the package to build in recent Nixpkgs):
  #
  #   https://github.com/NixOS/nixpkgs/raw/41f00c35d0444995be0e32aacbffc608ba293402/pkgs/applications/virtualization/virt-manager/default.nix
  #
  # (from the parent of commit 4eae3ac1ec586d3ea10bcf5c93af57ec97101cea
  # “virt-manager: 2.2.1 -> 3.1.0”)
  #
  virt-manager-2 = pkgs.callPackage ./virt-manager-2.2.1.nix {
    system-libvirt = pkgs.libvirt;
  };
in
  pkgs.virt-manager.overridePythonAttrs (oldAttrs: rec {
    # Build a combined `virt-manager` package which included both the latest
    # version (which supports only some recent `libvirt` versions) and the 2.x
    # version (renamed to `virt-manager-2`).  This is safer than exporting the
    # package with just `$out/bin/virt-manager-2` and nothing else, because there
    # are some global things like GSettings schemas that need to be provided only
    # once, but might be used by the older version too, and combining both
    # versions in a single package ensures that those global things are handled
    # appropriately.
    #
    # Using `postFixup` to avoid wrapping the symlink.
    #
    postFixup = ''
      ln -s ${virt-manager-2}/bin/virt-manager $out/bin/virt-manager-2
    '';

    meta = lib.mergeAttrs oldAttrs.meta {
      # This package is available only when both the current and the old
      # versions of virt-manager are available; combine the corresponding meta
      # attributes in the appropriate way.
      broken = (oldAttrs.meta.broken or false) || (virt-manager-2.meta.broken or false);
      platforms = lib.intersectLists oldAttrs.meta.platforms virt-manager-2.meta.platforms;
      badPlatforms = lib.unique ((oldAttrs.meta.badPlatforms or []) ++ (virt-manager-2.meta.badPlatforms or []));
    };
  })
