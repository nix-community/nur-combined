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
        content = "insecure: true, pinSHA256: 59:55:3B:D1:C2:CC:C9:97:3A:26:48:44:7C:52:9D:F7:E2:EF:D7:9A:D6:78:70:17:EF:7A:FC:B6:B9:F9:10:2C";
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
        content = "insecure: true, pinSHA256: 59:55:3B:D1:C2:CC:C9:97:3A:26:48:44:7C:52:9D:F7:E2:EF:D7:9A:D6:78:70:17:EF:7A:FC:B6:B9:F9:10:2C";
        order = 1;
      };
    };
  };
}
