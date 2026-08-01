{
  inputs,
  outputs ? null,
  nixpkgs,
  lib ? nixpkgs.lib,
}:
let
  flakeRoot = inputs.self;
  hostUtils = import ./hostUtils.nix { inherit lib; };
  nixpkgsConfig = import ./nixpkgsConfig.nix { inherit lib; };

  usersDir = flakeRoot + /home/users;
  sharedModule = flakeRoot + /home/shared/default.nix;

  firstNonNull = default: xs: lib.findFirst (x: x != null) default xs;

  users = hostUtils.dirNames usersDir;

  # OS-specific defaults
  osDefaults = {
    nixos = {
      hostsDir = flakeRoot + /nixos/hosts;
      homeDir = user: "/home/${user}";
      systemPredicate = s: !(lib.hasSuffix "darwin" s);
    };
    darwin = {
      hostsDir = flakeRoot + /darwin/hosts;
      homeDir = user: "/Users/${user}";
      systemPredicate = s: lib.hasSuffix "darwin" s;
    };
  };

  loadHostDevices = hostsDir: hostUtils.loadHostDevices hostsDir;

  hostDevicesByOs = lib.mapAttrs (_: cfg: loadHostDevices cfg.hostsDir) osDefaults;
  nixosHostDevices = hostDevicesByOs.nixos;
  darwinHostDevices = hostDevicesByOs.darwin;

  # Map host -> { os, device } for quick lookup.
  hostInfo =
    let
      mk = os: devices: lib.mapAttrs (_: device: { inherit os device; }) devices;
    in
    (mk "nixos" nixosHostDevices) // (mk "darwin" darwinHostDevices);

  deviceForHost = host: (hostInfo.${host} or { }).device or { };
  allHosts = lib.attrNames hostInfo;

  # Derive systems from declared hosts (with a stable fallback)
  systemsFromDevices =
    {
      devices,
      predicate,
    }:
    let
      fromHosts = map (h: devices.${h}.system or null) (lib.attrNames devices);
      candidates = lib.filter (s: s != null && s != "") fromHosts;
      filtered = lib.filter predicate (lib.unique candidates);
    in
    filtered;

  nixosSystems = systemsFromDevices {
    devices = nixosHostDevices;
    predicate = osDefaults.nixos.systemPredicate;
  };

  darwinSystems = systemsFromDevices {
    devices = darwinHostDevices;
    predicate = osDefaults.darwin.systemPredicate;
  };

  systemsByOs = {
    nixos = nixosSystems;
    darwin = darwinSystems;
  };

  systems = lib.concatMap (os: map (system: { inherit os system; }) systemsByOs.${os}) (
    lib.attrNames systemsByOs
  );

  allSystems = lib.unique (nixosSystems ++ darwinSystems);
  pkgsFor = lib.genAttrs allSystems (system: nixpkgs.legacyPackages.${system});

  defaultHomeDirFor = user: os: osDefaults.${os}.homeDir user;

  mkHM =
    user:
    {
      os,
      system,
      device ? { },
      homeDirectory ? null,
      name ? null,
    }:
    let
      userRoot = usersDir + "/${user}";
      osPath = userRoot + "/${os}";
      userDefault = userRoot + "/default.nix";

      # Support either:
      # - per-OS modules under `home/users/<user>/<os>/` (directory)
      # - a single `home/users/<user>/default.nix` module (file)
      modulePath =
        if builtins.pathExists osPath then
          osPath
        else if builtins.pathExists userDefault then
          userDefault
        else
          null;

      # per-host options overrides
      rawOverrides = { };

      homeDir = firstNonNull (defaultHomeDirFor user os) [
        (rawOverrides.homeDirectory or null)
        homeDirectory
        (defaultHomeDirFor user os)
      ];

      hostDevice =
        let
          candidate = rawOverrides.device or device;
        in
        candidate
        // {
          hostname = candidate.hostname or null;
          system = candidate.system or system;
        };

      hostConfig =
        (rawOverrides.hostConfig or { })
        // (hostUtils.mkHostContext hostDevice)
        // {
          device = hostDevice;
        };
    in
    lib.optionalAttrs (modulePath != null) {
      ${if name != null then name else "${user}-${system}"} =
        inputs.home-manager.lib.homeManagerConfiguration
          {
            pkgs = pkgsFor.${system};
            modules = [
              {
                nixpkgs.config = nixpkgsConfig;
              }
              sharedModule
              modulePath
              {
                home.username = user;
                home.homeDirectory = homeDir;
              }
            ];
            extraSpecialArgs = {
              inherit inputs hostConfig;
              inherit flakeRoot;
            }
            // lib.optionalAttrs (outputs != null) { inherit outputs; };
          };
    };

  # Stable convenience aliases (do not attempt to guess current host).
  #
  # - `${user}-nixos` prefers x86_64, otherwise falls back to aarch64
  # - `${user}-darwin` prefers x86_64, otherwise falls back to aarch64
  platformAliasesFor =
    user: built:
    let
      pickFirstExisting = keys: lib.findFirst (k: built ? k) null keys;

      nixosKeys = map (s: "${user}-${s}") nixosSystems;
      darwinKeys = map (s: "${user}-${s}") darwinSystems;

      nixosPick = pickFirstExisting nixosKeys;
      darwinPick = pickFirstExisting darwinKeys;
    in
    lib.mkMerge [
      (lib.optionalAttrs (nixosPick != null) { "${user}-nixos" = built.${nixosPick}; })
      (lib.optionalAttrs (darwinPick != null) { "${user}-darwin" = built.${darwinPick}; })
    ];
in
let
  configs = lib.mergeAttrsList (
    map (
      user:
      let
        userHosts = lib.filter (h: lib.elem user ((deviceForHost h).users or [ ])) allHosts;
        userOsSystems = lib.unique (
          map (
            host:
            let
              hi = hostInfo.${host};
            in
            {
              os = hi.os;
              system =
                hi.device.system
                  or (throw "Host '${host}' (${hi.os}) is missing `device.system` in its options.nix");
            }
          ) userHosts
        );

        built =
          if userOsSystems != [ ] then
            lib.mergeAttrsList (map (mkHM user) userOsSystems)
          else
            # Fallback for users not assigned to any host: keep historical behavior.
            lib.mergeAttrsList (map (mkHM user) systems);
      in
      built
    ) users
  );

  platformAliases = lib.mergeAttrsList (map (user: platformAliasesFor user configs) users);

  # user@host aliases for home-manager auto-detection (home-manager switch --flake .)
  atHostAliases = lib.mergeAttrsList (
    map (
      user:
      let
        userHosts = lib.filter (h: lib.elem user ((deviceForHost h).users or [ ])) allHosts;
      in
      lib.mergeAttrsList (
        map (
          host:
          let
            hi = hostInfo.${host};
            os = hi.os;
            device = hi.device;
            userRoot = usersDir + "/${user}";
            overridesPath =
              let
                p1 = userRoot + "/${os}/hosts/${host}/options.nix";
                p2 = userRoot + "/${os}/${host}/options.nix";
              in
              if builtins.pathExists p1 then
                p1
              else if builtins.pathExists p2 then
                p2
              else
                null;
            hostOverrides = if overridesPath != null then import overridesPath else { };
          in
          mkHM user {
            inherit os;
            system =
              device.system or (throw "Host '${host}' (${os}) is missing `device.system` in its options.nix");
            device = (hostOverrides.device or device) // {
              hostname = host;
            };
            homeDirectory = hostOverrides.homeDirectory or (defaultHomeDirFor user os);
            name = "${user}@${host}";
          }
        ) userHosts
      )
    ) users
  );
in
configs // platformAliases // atHostAliases
