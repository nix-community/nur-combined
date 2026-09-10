{
  lib,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  config.zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
