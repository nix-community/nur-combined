{ userConfig, ... }:

let
  extraGroupExtendedOptions = if userConfig.name == userConfig.group.name then
    { }
  else {
    "${userConfig.name}" = { };
  };

in {
  extraUsers = {
    "${userConfig.name}" = {
      inherit (userConfig) uid extraGroups;
      isSystemUser = true;
      createHome = false;
      description = "User account generated for running a specific service";
      group = "${userConfig.name}";
    };
  };

  extraGroups = {
    "${userConfig.group.name}" = { inherit (userConfig.group) gid members; };
  } // extraGroupExtendedOptions;
}
