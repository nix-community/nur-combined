{
  lib,
  stdenv,
  remmina,
}:

# nixpkgs' remmina uses GDK_IS_WAYLAND_DISPLAY unconditionally in src/rcw.c,
# but only includes <gdk/gdkwayland.h> when GDK_WINDOWING_WAYLAND is defined.
# The Darwin GTK3 build only has the Quartz backend, so the helper is undeclared
# there and the file fails to compile ("call to undeclared function
# 'GDK_IS_WAYLAND_DISPLAY'"). Guard it behind the same #ifdef.
remmina.overrideAttrs (old: {
  pname = "remmina_patched";

  patches =
    (old.patches or [ ])
    ++ lib.optional stdenv.hostPlatform.isDarwin ./darwin-no-gdk-wayland-display.patch;
})
