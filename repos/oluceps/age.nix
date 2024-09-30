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
        "restic-repo"
        "restic-repo-crit"
        "restic-envs"
        "restic-envs-crit"
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
        hyst-us-cli = {
          rekeyFile = ./sec/hyst-us-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us-cli.yaml";
        };
        hyst-la-cli = {
          rekeyFile = ./sec/hyst-la-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-la-cli.yaml";
        };
        hyst-hk-cli = {
          rekeyFile = ./sec/hyst-hk-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-hk-cli.yaml";
        };
      }
    );
  };
}
