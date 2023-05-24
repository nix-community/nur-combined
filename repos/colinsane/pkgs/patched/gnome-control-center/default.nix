{ gnome-control-center }:

(gnome-control-center.overrideAttrs (upstream: {
  # gnome-control-center does not start without XDG_CURRENT_DESKTOP=gnome
  # see: <https://github.com/NixOS/nixpkgs/issues/230493>
  # see: <https://gitlab.gnome.org/GNOME/gnome-control-center/-/merge_requests/736>
  #
  # non-gnome DEs (e.g. sway) already set XDG_CURRENT_DESKTOP to something different,
  # so changing this system-wide probably isn't a good idea.
  preFixup = ''
    gappsWrapperArgs+=(
      --set XDG_CURRENT_DESKTOP "gnome"
    );
  '' + upstream.preFixup;
}))
