{
  # Add your overlays here
  gnome-text-input-v1 = (prev: final: {
    gnome = prev.gnome.overrideScope (
      gfinal: gprev: {
        mutter = prev.callPackage ../pkgs/by-name/mutter-text-input-v1.nix {};
        gnome-shell = prev.callPackage ../pkgs/by-name/gnome-shell-fix-preedit-cursor.nix {};
      }
    );
  });
}
