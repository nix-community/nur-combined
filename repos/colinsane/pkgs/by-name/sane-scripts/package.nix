{
  lib,
  nix,
  sane-bt-add,
  sane-bt-rm,
  sane-bt-search,
  sane-bt-show,
  sane-clone,
  sane-date-set,
  sane-deadlines,
  sane-dev-cargo-loop,
  sane-find-dotfiles,
  sane-ip-check,
  sane-ip-port-forward,
  sane-private-do,
  sane-private-unlock,
  sane-private-unlock-remote,
  sane-profile,
  sane-rcp,
  sane-reboot,
  sane-reclaim-boot-space,
  sane-reclaim-disk-space,
  sane-secrets-dump,
  sane-secrets-unlock,
  sane-secrets-update-keys,
  sane-shutdown,
  sane-stop-all-servo,
  sane-sudo-redirect,
  sane-sync-from-iphone,
  sane-sync-music,
  sane-tag-media,
  sane-vpn,
  sane-which,
  sane-wipe,
}:

lib.recurseIntoAttrs {
  bt-add = sane-bt-add;
  bt-rm = sane-bt-rm;
  bt-search = sane-bt-search;
  bt-show = sane-bt-show;
  clone = sane-clone.override { inherit nix; };
  date-set = sane-date-set;
  deadlines = sane-deadlines;
  dev-cargo-loop = sane-dev-cargo-loop;
  find-dotfiles = sane-find-dotfiles;
  ip-check = sane-ip-check;
  ip-port-forward = sane-ip-port-forward;
  private-do = sane-private-do;
  private-unlock = sane-private-unlock;
  private-unlock-remote = sane-private-unlock-remote;
  profile = sane-profile;
  rcp = sane-rcp;
  reboot = sane-reboot;
  reclaim-boot-space = sane-reclaim-boot-space;
  reclaim-disk-space = sane-reclaim-disk-space.override { inherit nix; };
  secrets-dump = sane-secrets-dump;
  secrets-unlock = sane-secrets-unlock;
  secrets-update-keys = sane-secrets-update-keys;
  shutdown = sane-shutdown;
  stop-all-servo = sane-stop-all-servo;
  sudo-redirect = sane-sudo-redirect;
  sync-from-iphone = sane-sync-from-iphone;
  sync-music = sane-sync-music;
  tag-media = sane-tag-media;
  vpn = sane-vpn;
  which = sane-which;
  wipe = sane-wipe;
}
