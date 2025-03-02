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
  hyst-osa-cli = {
    file = ../sec/hyst-cli.age;
    cleanPlaceholder = true;
    insert = {
      "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
        content = "172.234.92.148";
        order = 0;
      };
      "b1ca20eb6f34aa70cc00682636eb3582d592727923789fed0eeb56fa567d5c01" = {
        content = "insecure: true, pinSHA256: 6D:C7:B5:6E:12:1E:9B:79:D1:79:C4:EA:72:E0:BB:5A:5B:AF:48:4F:75:7E:A1:DC:D3:CD:0F:8C:73:35:7A:0A";
        order = 1;
      };
    };
  };
  hyst-hk-cli = {
    file = ../sec/hyst-cli.age;
    cleanPlaceholder = true;
    insert = {
      "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
        content = "8.210.47.13";
        order = 0;
      };
    };
  };
}
