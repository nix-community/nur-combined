{ lib, qq-wayland-fix }:

# Deprecated: upstream superseded linuxqq-wayland-screenshare-fix with
# linuxqq-wayland-fix, which is the maintained replacement. Keep the old
# attribute evaluating so existing configurations keep working. The warning is
# attached to meta rather than to the package value so it fires when the alias
# is actually built or inspected (`nix build .#qq-wlss`, `nix-env -qa --meta`)
# and not when the flake enumerates the package set to build something else.
qq-wayland-fix // {
  meta = lib.warn "qq-wlss is deprecated: linuxqq-wayland-screenshare-fix was superseded upstream; use qq-wayland-fix instead" qq-wayland-fix.meta;
}
