# FirefoxPWA XWayland

`firefoxpwa` wrapped with `MOZ_ENABLE_WAYLAND=0`. This works around corrupted Firefox browser chrome and popups under native Wayland fractional scaling.

## Install

```nix
home.packages = [ pkgs.nur.repos.so1ve.firefoxpwa-xwayland ];

programs.firefox.nativeMessagingHosts = [
  pkgs.nur.repos.so1ve.firefoxpwa-xwayland
];
```
