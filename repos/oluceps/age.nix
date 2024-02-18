{ data, lib, user, ... }:
{

  age = {

    rekey = {
      extraEncryptionPubkeys = [ data.keys.ageKey ];
      masterIdentities = [ ./sec/age-yubikey-identity-7d5d5540.txt.pub ];
    };

    secrets =
      let
        gen = ns: owner: group: mode: lib.genAttrs ns (n: { rekeyFile = ./sec/${n}.age;  inherit owner group mode; });
        genProxys = i: gen i "root" "users" "400";
        genMaterial = i: gen i user "users" "400";
        genBoot = i: gen i "root" "root" "400";
        genWg = i: gen i "systemd-network" "root" "400";
      in
      (genProxys [ "rat" "ss" "sing" "hyst-us" "tuic" "naive" "dae.sub" "jc-do" "juic-san" "tuic-san" "caddy-lsa" "ss-az" ]) //
      (genMaterial [ "minisign.key" "ssh-cfg" "gh-eu" "riro.u2f" "elen.u2f" "gh-token" "age" "pub" "id" "id_sk" "minio" "prism" "aws-s3-cred" "vault" "restic-repo" "restic-envs" ]) //
      (genBoot [ "db.key" "db.pem" ]) //
      (genWg [ "wg" "wgk" "wgy" "wga" "wgc-warp" "wge" ]) //
      {
        dae = { rekeyFile = ./sec/dae.age; mode = "640"; owner = "root"; group = "users"; name = "d.dae"; };
        "nyaw.key" = { rekeyFile = ./sec/nyaw.key.age; mode = "640"; owner = "root"; group = "users"; };
        "nyaw.cert" = { rekeyFile = ./sec/nyaw.cert.age; mode = "640"; owner = "root"; group = "users"; };
        hyst-us = { rekeyFile = ./sec/hyst-us.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-us.yaml"; };
        hyst-us-cli = { rekeyFile = ./sec/hyst-us-cli.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-us-cli.yaml"; };
        hyst-us-cli-has = { rekeyFile = ./sec/hyst-us-cli-has.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-us-cli-has.yaml"; };
        hyst-az-cli-has = { rekeyFile = ./sec/hyst-az-cli-has.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-has.yaml"; };
        hyst-az-cli-kam = { rekeyFile = ./sec/hyst-az-cli-kam.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-kam.yaml"; };
        atuin = { rekeyFile = ./sec/atuin.age; mode = "640"; owner = user; group = "users"; };
        atuin_key = { rekeyFile = ./sec/atuin_key.age; mode = "640"; owner = user; group = "users"; };
      };
  };
}
