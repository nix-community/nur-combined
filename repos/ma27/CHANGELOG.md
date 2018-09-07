# Changelog

Document to track fundemental changes to this NUR repository.

## 2018-09-07

* Dropped `lib/hetzner`. I don't use `hetzner.cloud` servers anymore, therefore removal (for now).

## 2018-09-02

* Dropped `modules.weechat`. `nixpgks` features `services.weechat` and a init/script configuration API
  including the `weechatScripts` metapackage for helper scripts to be
  loaded in weechat (See [#45728](https://github.com/NixOS/nixpkgs/pull/45728)).
* Added `lib/release` with several helpers for Hydra jobs.
* Dropped `sql-developer` overlay. Instead `sqldeveloper_18` from `<nixpkgs>` should be used.
