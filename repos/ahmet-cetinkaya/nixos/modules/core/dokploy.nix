{inputs, ...}: {
  imports = [inputs.nix-dokploy.nixosModules.default];

  services.dokploy = {
    enable = true;
    database.passwordFile = "/var/lib/secrets/dokploy-db-password";
    auth.secretFile = "/var/lib/secrets/dokploy-auth-secret";
    encryption.keyFile = "/var/lib/secrets/dokploy-encryption-key";
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
