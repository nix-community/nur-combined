{ pkgs, ... }:
(builtins.toJSON {
  base_url = "https://vault.nyaw.xyz";
  client_cert_path = null;
  email = "i@nyaw.xyz";
  identity_url = null;
  lock_timeout = 3600;
  notifications_url = null;
  # pinentry = "${pkgs.wayprompt}/bin/pinentry-wayprompt";
  pinentry = "${pkgs.pinentry-gnome3}/bin/pinentry";
  sso_id = null;
  sync_interval = 3600;
  ui_url = "https://vault.nyaw.xyz";
})
