{
  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = "/etc/nix/cache-priv-key.pem";
  };
}
