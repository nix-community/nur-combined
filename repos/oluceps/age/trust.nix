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
  "on-hastur.toml"
  "jc-do"
  "ss-az"
  "naive"
])
// (userRo [
  "atuin"
  "atuin_key"
  "pam"
  "age"
  "pub"
  "minio"
  "aws-s3-cred"
  "attic"
])
// (rootRo [
  "db.key"
  "db.pem"
  "dae"
])
// (
  let
    genHyst = name: addr: {
      "hyst-${name}-cli" = {
        file = ../sec/hyst-cli.age;
        insert = {
          "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
            content = addr;
            order = 0;
          };
        };
      };
    };
  in
  lib.concatMapAttrs genHyst {
    osa = "172.234.92.148";
    hk = "8.210.47.13";
  }
)
