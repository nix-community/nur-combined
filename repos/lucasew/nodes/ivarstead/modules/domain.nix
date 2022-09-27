{config, lib, ...}:
{
  options.vps.domain = lib.mkOption {
    description = "VPS root domain";
    type = lib.types.str;
    default = "vps.local";
  };
}
