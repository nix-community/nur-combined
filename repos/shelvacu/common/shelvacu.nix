{
  config,
  lib,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  users.users.shelvacu = lib.mkIf (!config.vacu.isContainer) {
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "dialout"
    ];
  };
}
