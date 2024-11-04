{
  hard,
  userRo,
  rootRo,
  lib,
  # sdnetRo,
  # rrr,
  ...
}:
(hard [
  "general.toml"
  "on-kaambl.toml"
  "on-eihort.toml"
  "jc-do"
  "ss-az"
  "naive"
])
// (userRo [
  "atuin"
  "atuin_key"
  "ssh-cfg"
  "riro.u2f"
  "elen.u2f"
  "age"
  "pub"
  "minio"
  "aws-s3-cred"
  "attic"
])
// (rootRo [
  "db.key"
  "db.pem"
])
// {
  dae = {
    file = ../sec/dae.age;
    mode = "640";
    owner = "root";
    group = "users";
    name = "d.dae";
  };

}
// (
  let
    inherit (lib) listToAttrs nameValuePair;
  in
  listToAttrs (
    map
      (
        n:
        nameValuePair "hyst-${n}-cli" {
          file = ../sec/hyst-${n}-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-${n}-cli.yaml";
        }
      )
      [
        "la"
        "us"
        "hk"
      ]
  )
)
