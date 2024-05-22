{
  config,
  data,
  lib,
  user,
  ...
}:
{

  age = {

    rekey = {
      extraEncryptionPubkeys = [ data.keys.ageKey ];
      masterIdentities = [ ./sec/age-yubikey-identity-7d5d5540.txt.pub ];
      storageMode = "local";
      localStorageDir = ./sec/rekeyed/${config.networking.hostName};
    };

    secrets = (
      let
        gen =
          ns: owner: group: mode:
          lib.genAttrs ns (n: {
            rekeyFile = ./sec/${n}.age;
            inherit owner group mode;
          });
        genProxys = i: gen i "root" "users" "400";
        genMaterial = i: gen i user "users" "400";
        genBoot = i: gen i "root" "root" "400";
        genWg = i: gen i "systemd-network" "root" "400";
        genGlobalR = i: gen i "root" "root" "444";
      in
      (genProxys [
        "ss"
        "sing"
        "hyst-us"
        "juic-san"
        "naive"
        "dae.sub"
        "jc-do"
        "ss-az"
        "trojan-server"
      ])
      // (genMaterial [
        "atuin"
        "atuin_key"
        "ssh-cfg"
        "riro.u2f"
        "elen.u2f"
        "gh-token"
        "age"
        "pub"
        "minio"
        "prism"
        "aws-s3-cred"
        "vault"
        "restic-repo"
        "restic-repo-crit"
        "restic-envs"
        "restic-envs-crit"
        "attic"
        "radicle-pass"
      ])
      // (genBoot [
        "db.key"
        "db.pem"
      ])
      // (genWg [
        "wg"
        "wgk"
        "wgy"
        "wga"
        "wgc-warp"
        "wge"
      ])
      // (genGlobalR [ "ntfy-token" ])
      // {
        dae = {
          rekeyFile = ./sec/dae.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "d.dae";
        };
        "nyaw.key" = {
          rekeyFile = ./sec/nyaw.key.age;
          mode = "640";
          owner = "root";
          group = "users";
        };
        "nyaw.cert" = {
          rekeyFile = ./sec/nyaw.cert.age;
          mode = "640";
          owner = "root";
          group = "users";
        };
        hyst-us = {
          rekeyFile = ./sec/hyst-us.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us.yaml";
        };
        hyst-us-cli = {
          rekeyFile = ./sec/hyst-us-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us-cli.yaml";
        };
        hyst-az-cli = {
          rekeyFile = ./sec/hyst-az-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-az-cli.yaml";
        };
      }
    );
  };
}
