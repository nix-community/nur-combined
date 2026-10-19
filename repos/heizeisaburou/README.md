# nur-packages

**heizeisaburou's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/heizeisaburou/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

| Package | Description |
| --- | --- |
| [uxsm](https://github.com/heizeisaburou/uxsm) | X11 session manager for `systemd --user`, the X11 counterpart of uwsm |

With NUR set up as its README explains, the package is `nur.repos.heizeisaburou.uxsm`:

```nix
environment.systemPackages = [ pkgs.nur.repos.heizeisaburou.uxsm ];
```

uxsm is young and still in testing; its [README](https://github.com/heizeisaburou/uxsm#status) says where it stands.
