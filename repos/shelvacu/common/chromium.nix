{ lib, vacuModuleType, ... }:
lib.optionalAttrs (vacuModuleType == "nixos") {
  environment = {
    pathsToLink = [ "/etc/chromium" ];
    etc."chromium".source = "/run/current-system/sw/etc/chromium";
  };
}
