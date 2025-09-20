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
  "ss-az"
])
// (userRo [
  "atuin"
  "atuin_key"
  "pam"
  "age"
  "id_sk"
])
// (rootRo [
  "db.key"
  "db.pem"
  "dae"
])
// {
  hyst-tyo-cli = {
    file = ../sec/hyst-cli.age;
    cleanPlaceholder = true;
    insert = {
      "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
        content = "[" + (lib.elemAt lib.data.node.abhoth.addrs 0) + "]"; # IPv6, straight
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
        content = "[" + (lib.elemAt lib.data.node.yidhra.addrs 0) + "]"; # IPv6, straight
        order = 0;
      };
      "b1ca20eb6f34aa70cc00682636eb3582d592727923789fed0eeb56fa567d5c01" = {
        content = "ca: ${lib.data.ca_cert.root_file}";
        order = 1;
      };
    };
  };
}
