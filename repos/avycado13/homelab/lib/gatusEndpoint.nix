{
  lib,
  name,
  url,
}:
lib.mkOption {
  type = lib.types.nullOr (
    lib.types.submodule {
      options = {
        url = lib.mkOption {
          type = lib.types.str;
          default = url;
          description = "URL Gatus checks for ${name}";
        };
        condition = lib.mkOption {
          type = lib.types.str;
          default = "[STATUS] < 400";
          description = "Gatus condition for ${name}";
        };
        interval = lib.mkOption {
          type = lib.types.str;
          default = "5m";
          description = "How often Gatus checks ${name}";
        };
      };
    }
  );
  default = { };
  description = "Gatus check for ${name}; set to null to omit it";
}
