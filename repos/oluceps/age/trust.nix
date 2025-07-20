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
  "aws-s3-cred"
  "attic"
])
// (rootRo [
  "db.key"
  "db.pem"
  "dae"
])
// {
  hyst-osa-cli = {
    file = ../sec/hyst-cli.age;
    cleanPlaceholder = true;
    insert = {
      "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
        content = "172.234.92.148";
        order = 0;
      };
      "b1ca20eb6f34aa70cc00682636eb3582d592727923789fed0eeb56fa567d5c01" = {
        content = "ca: ${lib.data.ca_cert.root_file}";
        order = 1;
      };
    };
  };
  hyst-hk-cli = {
    file = ../sec/hyst-cli.age;
    cleanPlaceholder = true;
    insert = {
      "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
        content = "103.213.4.159";
        order = 0;
      };
      "b1ca20eb6f34aa70cc00682636eb3582d592727923789fed0eeb56fa567d5c01" = {
        content = "ca: ${lib.data.ca_cert.root_file}";
        order = 1;
      };
    };
  };
}
