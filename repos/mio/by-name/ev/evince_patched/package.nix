{
  lib,
  stdenv,
  evince,
  gnome-desktop,
  desktopToDarwinBundle,
}:

let
  # nixpkgs marks gnome-desktop as bad on Darwin, which makes evaluation of
  # anything depending on it abort. Its Linux-only pieces (udev, systemd,
  # bubblewrap, wayland, seccomp) are already gated on
  # stdenv.hostPlatform.isLinux; the one unconditional Linux header is the
  # personality(2) include used only by the seccomp sandbox path.
  gnome-desktop-darwin =
    if stdenv.hostPlatform.isDarwin then
      gnome-desktop.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./gnome-desktop-darwin-personality.patch ];
        meta = (old.meta or { }) // {
          badPlatforms = [ ];
        };
      })
    else
      gnome-desktop;
in
(evince.override { gnome-desktop = gnome-desktop-darwin; }).overrideAttrs (old: {
  nativeBuildInputs =
    (old.nativeBuildInputs or [ ]) ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;
})
