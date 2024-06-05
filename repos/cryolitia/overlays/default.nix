{ packages }:
{
  # Add your overlays here
  nur-cryolitia = (final: prev: { nur-cryolitia = packages."${prev.system}"; });
  gnome-text-input-v1 = (
    prev: final: {
      gnome = prev.gnome.overrideScope (
        gfinal: gprev: {
          mutter = gprev.callPackage ../pkgs/pkgs/by-name/mutter-text-input-v1 { };
          gnome-shell = gprev.callPackage ../pkgs/by-name/gnome-shell-fix-preedit-cursor { };
        }
      );
    }
  );
}
