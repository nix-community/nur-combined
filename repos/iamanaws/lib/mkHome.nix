{
  hostRegistry,
  inputs,
  outputs ? null,
  nixpkgs,
  lib ? nixpkgs.lib,
}:
let
  flakeRoot = inputs.self;
  hostUtils = import ./hostUtils.nix { inherit lib; };
  nixpkgsConfig = import ./nixpkgsConfig.nix { inherit lib; };
  homeUsersRoot = flakeRoot + /home/users;

  defaultHomeDirectory =
    backend: user: if backend == "darwin" then "/Users/${user}" else "/home/${user}";

  assignments = lib.concatMap (
    host:
    map (userSpec: {
      inherit host userSpec;
      canonicalName = "${userSpec.name}@${host.name}";
    }) (lib.filter (userSpec: userSpec.homeManager.enable) host.users)
  ) hostRegistry.all;

  canonicalNames = map (assignment: assignment.canonicalName) assignments;

  mkHomeConfiguration =
    assignment:
    let
      inherit (assignment) host userSpec;
      inherit (host) backend;
      inherit (userSpec) name;
      system =
        host.device.system
          or (throw "Host '${host.name}' (${backend}) is missing `device.system` in its options.nix");
      modulePath = hostUtils.mkHmModulePath {
        inherit backend homeUsersRoot;
        knownBackends = hostRegistry.backends;
        user = name;
        hmModuleMode = userSpec.homeManager.module;
      };
      hostConfig = hostUtils.mkHostContext host.device // {
        inherit (host) device;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
        {
          nixpkgs.config = nixpkgsConfig;
        }
        modulePath
        {
          home.username = name;
          home.homeDirectory = defaultHomeDirectory backend name;
        }
      ];
      extraSpecialArgs = {
        inherit inputs hostConfig;
        inherit flakeRoot;
      }
      // lib.optionalAttrs (outputs != null) { inherit outputs; };
    };

  canonical =
    assert lib.assertMsg (
      builtins.length canonicalNames == builtins.length (lib.unique canonicalNames)
    ) "Duplicate standalone Home Manager user@host output names: ${toString canonicalNames}";
    lib.listToAttrs (
      map (
        assignment: lib.nameValuePair assignment.canonicalName (mkHomeConfiguration assignment)
      ) assignments
    );

  aliasesFor =
    suffixFor:
    lib.listToAttrs (
      lib.filter (entry: entry != null) (
        map (
          assignment:
          let
            suffix = suffixFor assignment;
            matching = lib.filter (
              candidate: candidate.userSpec.name == assignment.userSpec.name && suffixFor candidate == suffix
            ) assignments;
          in
          if builtins.length matching == 1 then
            lib.nameValuePair "${assignment.userSpec.name}-${suffix}" canonical.${assignment.canonicalName}
          else
            null
        ) assignments
      )
    );

  systemAliases = aliasesFor (assignment: assignment.host.device.system);
  backendAliases = aliasesFor (assignment: assignment.host.backend);
in
canonical // systemAliases // backendAliases
