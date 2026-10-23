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
      homeDerivations = map (
        user: inputs.self.homeConfigurations."${user.name}@${host.name}".activationPackage.drvPath
      ) (lib.filter (user: user.homeManager.enable) host.users);
    in
    # Force real module evaluation, but don't make system closures build inputs.
    assert builtins.deepSeq systemConfig.config.device true;
    assert builtins.deepSeq ([ systemDerivation.drvPath ] ++ homeDerivations) true;
    pkgs.runCommand "integration-${host.name}" { } ''
      touch "$out"
    '';
in
lib.listToAttrs (
  map (host: lib.nameValuePair "integration-${host.name}" (checkHost host)) nativeHosts
)
