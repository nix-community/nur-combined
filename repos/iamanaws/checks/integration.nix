{
  pkgs,
  inputs,
  hostRegistry,
}:
let
  inherit (pkgs) lib;

  # Explicit rollout scope; legacy/test hosts and Charles's migration stay out.
  activeHosts = [
    hostRegistry.byBackend.nixos.archimedes
    hostRegistry.byBackend.nixos.goliath
    hostRegistry.byBackend.darwin.galileo
  ];
  nativeHosts = lib.filter (host: host.device.system == pkgs.stdenv.hostPlatform.system) activeHosts;

  checkHost =
    host:
    let
      systemConfig = inputs.self.${host.backend + "Configurations"}.${host.name};
      systemDerivation =
        if host.backend == "darwin" then systemConfig.system else systemConfig.config.system.build.toplevel;
      enabledUsers = lib.filter (user: user.homeManager.enable) host.users;
      homeDerivations = map (
        user: inputs.self.homeConfigurations."${user.name}@${host.name}".activationPackage.drvPath
      ) enabledUsers;
      matchingShells = lib.all (
        user:
        let
          integrated = systemConfig.config.home-manager.users.${user.name}.programs.bash;
          standalone = inputs.self.homeConfigurations."${user.name}@${host.name}".config.programs.bash;
        in
        lib.all (option: integrated.${option} == standalone.${option}) [
          "bashrcExtra"
          "initExtra"
          "profileExtra"
        ]
      ) enabledUsers;
    in
    # Force real module evaluation, but don't make system closures build inputs.
    assert builtins.deepSeq systemConfig.config.device true;
    assert lib.assertMsg (
      systemConfig.config.device == host.device
    ) "${host.name}: system device data differs from the host registry";
    assert lib.assertMsg matchingShells
      "${host.name}: integrated and standalone Home Manager shell startup differs";
    assert lib.assertMsg (
      !host.hostConfig.hyprland
      || lib.any (
        package: lib.elem "hyprland" package.providedSessions
      ) systemConfig.config.services.displayManager.sessionPackages
    ) "${host.name}: Hyprland is missing from the registered login sessions";
    assert builtins.deepSeq ([ systemDerivation.drvPath ] ++ homeDerivations) true;
    pkgs.runCommand "integration-${host.name}" { } ''
      ${lib.optionalString host.hostConfig.hyprland (
        lib.concatMapStringsSep "\n" (
          user:
          let
            homeConfig = inputs.self.homeConfigurations."${user.name}@${host.name}".config;
            expectedStartup = if homeConfig.wayland.windowManager.hyprland.enable then "hyprland" else "shell";
            loginScript = pkgs.writeText "${user.name}-${host.name}-login.sh" homeConfig.programs.bash.profileExtra;
          in
          "bash ${./hyprland-login.sh} ${loginScript} ${expectedStartup}"
        ) enabledUsers
      )}
      touch "$out"
    '';
in
lib.listToAttrs (
  map (host: lib.nameValuePair "integration-${host.name}" (checkHost host)) nativeHosts
)
