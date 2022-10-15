self: super: {
  xdg-desktop-portal = super.xdg-desktop-portal.overrideAttrs(oldAttrs: {
    patches = [
      ./fix-removing-directories.patch
    ];
  });

  xdg-desktop-portal-gtk = super.xdg-desktop-portal-gtk.overrideAttrs(oldAttrs: {
    postInstall = ''
      mv $out/share/xdg-desktop-portal/portals/{,zz-}gtk.portal
    '';
  });
}
