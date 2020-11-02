# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/berbiche/nur/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-berbiche-blue.svg)](https://berbiche.cachix.org)

## My packages

Mostly Wayland related stuff.

- [deadd-notification-center](https://github.com/phuhl/linux_notification_center)
- [mpvpaper](https://github.com/GhostNaN/mpvpaper)
- [waylock](https://github.com/ifreund/waylock) - Requires `security.pam.services.waylock = {};`
  or `security.pam.services.waylock.unixAuth = true;` to authenticate the user
- [wlclock](https://github.com/Leon-Plickat/wlclock)
- [wlr-sunclock](https://github.com/sentriz/wlr-sunclock)

## My modules

### nixos

### home-manager

- `modules.home-manager.deadd-notification-center`: notification daemon and notification center

## TODOs

- [x] [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository)
