{ lib, qq-wayland-fix }:

# Deprecated: upstream superseded linuxqq-wayland-screenshare-fix with
# linuxqq-wayland-fix, which is the maintained replacement. Keep the old
# attribute evaluating so existing configurations keep working.
lib.warn "qq-wlss is deprecated: linuxqq-wayland-screenshare-fix was superseded upstream; use qq-wayland-fix instead" qq-wayland-fix
