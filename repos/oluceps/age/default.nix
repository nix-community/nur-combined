{
  config,
  data,
  lib,
  user,
  self,
  ...
}:
{

  age = {

    rekey = {
      extraEncryptionPubkeys = [ data.keys.ageKey ];
      masterIdentities = [
        (self + "/sec/age-yubikey-identity-7d5d5540.txt.pub")
      ];
      storageMode = "local";
      localStorageDir = self + "/sec/rekeyed/${config.networking.hostName}";
    };

    secrets = (
      let
        gen =
          ns: owner: group: mode:
          lib.genAttrs ns (n: {
            rekeyFile = ../sec/${n}.age;
            inherit owner group mode;
          });
        genHard = i: gen i "root" "users" "400";
        genMaterial = i: gen i user "users" "400";
        genBoot = i: gen i "root" "root" "400";
        genWg = i: gen i "systemd-network" "root" "400";
        genGlobalR = i: gen i "root" "root" "444";
      in
      (genHard [
        "ss"
        "sing"
        "juic-san"
        "naive"
        "dae.sub"
        "jc-do"
        "ss-az"
        "trojan-server"
        "caddy"
        "general.toml"
      ])
      // (genMaterial [

        "nyaw.cert"
        "nyaw.key"
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
        # "rustic-repo"
        # "rustic-repo-crit"
        # "rustic-envs"
        # "rustic-envs-crit"
        "attic"
      ])
      // (genBoot [
        "db.key"
        "db.pem"
      ])
      // (genWg [ "wg" ])
      // (genGlobalR [ "ntfy-token" ])
      // {
        dae = {
          rekeyFile = ../sec/dae.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "d.dae";
        };
        hyst-us-cli = {
          rekeyFile = ../sec/hyst-us-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us-cli.yaml";
        };
        hyst-la-cli = {
          rekeyFile = ../sec/hyst-la-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-la-cli.yaml";
        };
        hyst-hk-cli = {
          rekeyFile = ../sec/hyst-hk-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-hk-cli.yaml";
        };
      }
    );
  };
}
