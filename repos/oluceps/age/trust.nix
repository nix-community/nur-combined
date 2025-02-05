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
// {
  hyst-osa-cli.file = ../sec/hyst-osa-cli.age;
  hyst-hk-cli.file = ../sec/hyst-hk-cli.age;
}
