# This module assumes the existence of a suitably generated keypair within /var
# To generate this, either follow the instructions here: https://nixos.wiki/wiki/Binary_Cache
# or:
# cd /var
# nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem
# chown nix-serve cache-priv-key.pem
# chmod 600 cache-priv-key.pem
# cat cache-pub-key.pem
{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
    # The port is just the same as default, but included here to ensure documentation of
    # the value
    port = 5000;
    openFirewall = true;
  };
}
