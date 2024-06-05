{ packages }:
{
  # Add your overlays here
  nur-cryolittia = (final: prev: { nur-cryolitia = packages."${prev.system}"; });
  gnome-text-input-v1 = (prev: final: {
    gnome = prev.gnome.overrideScope (
      gfinal: gprev: {
        mutter = packages.mutter-text-input-v1;
        gnome-shell = packages.gnome-shell-fix-preedit-cursor;
      }
    );
  });
}
