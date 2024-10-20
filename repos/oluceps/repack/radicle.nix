{
  lib,
  reIf,
  config,
  ...
}:
reIf {
  services.radicle = {
    enable = true;
    httpd = {
      enable = true;
      listenPort = 8084;
      listenAddress = "10.0.1.2";
    };
    node.openFirewall = true;
    privateKeyFile = config.age.secrets.id.path;
    publicKey = lib.data.keys.sshPubKey;
    settings = {
      cli = {
        hints = true;
      };
      node = {
        alias = "nodens";
        connect = [ ];
        externalAddresses = [ "seed.nyaw.xyz:8776" ];
        limits = {
          connection = {
            inbound = 128;
            outbound = 16;
          };
          fetchConcurrency = 1;
          gossipMaxAge = 1209600;
          maxOpenFiles = 4096;
          rate = {
            inbound = {
              capacity = 32;
              fillRate = 0.2;
            };
            outbound = {
              capacity = 64;
              fillRate = 1;
            };
          };
          routingMaxAge = 604800;
          routingMaxSize = 1000;
        };
        listen = [ ];
        network = "main";
        peers = {
          target = 8;
          type = "dynamic";
        };
        policy = "block";
        relay = true;
        scope = "all";
        workers = 8;
      };
      preferredSeeds = [
        "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@seed.radicle.garden:8776"
        "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@ash.radicle.garden:8776"
      ];
      publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
      # web = {
      # pinned = {
      # repositories = [ "z2BAxuSMWoD3JujdWKCS3FoYEXE6V" ];
      # };
      # };
    };
  };
}
