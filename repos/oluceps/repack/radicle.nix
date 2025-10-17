{
  lib,
  reIf,
  config,
  inputs',
  ...
}:
reIf {
  services.radicle = {
    enable = true;
    # package = pkgs.radicle;
    httpd = {
      enable = true;
      listenPort = 8084;
      listenAddress = "[::]";
    };
    node.openFirewall = true;
    privateKeyFile = config.vaultix.secrets.id.path;
    publicKey = lib.data.keys.sshPubKey;
    settings = {
      cli = {
        hints = true;
      };
      node = {
        alias = "nyawyz";
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
        "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.xyz:8776"
        "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.xyz:8776"
      ];
      publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
      web = {
        avatarUrl = "https://raw.githubusercontent.com/milieuim/mdbook-theme-milieuim/refs/heads/main/favicon.svg";
        bannerUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/15_Qian_Xuan_Eight_Flowers_National_Palace_Museum_Beijing.JPG/2560px-15_Qian_Xuan_Eight_Flowers_National_Palace_Museum_Beijing.JPG";
        description = "radicle seed hosted on nyaw.xyz";
        pinned = {
          repositories = [
            "rad:z23fw6Ewk1bJvxg2K83a4qNngtwNN"
            "rad:z4DLk3sKs4Fy589WwVBcrXF6B8KES"
            "rad:z2Z5YGxHrosERS5LhGrSg3jBhndv2"
          ];
        };
      };
    };
  };
}
