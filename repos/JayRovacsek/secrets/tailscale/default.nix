let
  primaryTailscaleKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFufEoK+LGcpNy7PnCih/LwwrjANruawcCzeh2INnZ0A";
  secondaryTailscaleKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSITKapgYMXOYu/OeVznsQlRkrl6gScyuR9PA2z+hA7";
  tailscaleKeys = [ primaryTailscaleKey secondaryTailscaleKey ];
in {
  ## Tailscale preauth keys
  "preauth-admin.age".publicKeys = tailscaleKeys;
  "preauth-auth.age".publicKeys = tailscaleKeys;
  "preauth-dns.age".publicKeys = tailscaleKeys;
  "preauth-download.age".publicKeys = tailscaleKeys;
  "preauth-game.age".publicKeys = tailscaleKeys;
  "preauth-general.age".publicKeys = tailscaleKeys;
  "preauth-log.age".publicKeys = tailscaleKeys;
  "preauth-nextcloud.age".publicKeys = tailscaleKeys;
  "preauth-reverse-proxy.age".publicKeys = tailscaleKeys;
  "preauth-work.age".publicKeys = tailscaleKeys;
}
