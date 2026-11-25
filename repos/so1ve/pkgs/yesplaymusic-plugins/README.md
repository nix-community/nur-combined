# YesPlayMusic plugins

Pass plugins to [`yesplaymusic.withPlugins`](../yesplaymusic/README.md).

| Plugin | Upstream | Purpose |
| --- | --- | --- |
| `emby` | `qier222/ypm-plugin-emby` | Official Emby media server source |
| `jellyfin` | `qier222/ypm-plugin-jellyfin` | Official Jellyfin media server source |
| `netease` | `lymzzyh/ypm-plugin-netease` | NetEase Cloud Music source |
| `plex` | `qier222/ypm-plugin-plex` | Official Plex media server source |
| `qqmusic` | `lymzzyh/ypm-plugin-qqmusic` | QQ Music source (enable local program permission in Settings for QR login) |
| `subsonic` | `qier222/ypm-plugin-subsonic` | Official Subsonic / Navidrome source |

Each packaged plugin strips `repository` from `plugin.json` so YesPlayMusic does
not prompt for or auto-install in-app updates over Nix-managed symlinks.

## Updating

Update your NUR or flake input to update YesPlayMusic and its plugins.
