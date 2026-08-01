{ lib }:
let
  # List only directories under a given path (stable + matches how flake.nix enumerates hosts).
  dirNames = dir: lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir));

  # Load `{ device = ...; }` from `<path>/options.nix` when present.
  loadDeviceConfig =
    path:
    let
      optionsPath = path + "/options.nix";
    in
    if builtins.pathExists optionsPath then (import optionsPath).device or { } else { };

  # Load device configs for each host in a hosts directory (e.g. ./nixos/hosts).
  loadHostDevices =
    hostsDir: lib.genAttrs (dirNames hostsDir) (name: loadDeviceConfig (hostsDir + "/${name}"));

  # Build a nested attrset of **module paths** from a directory tree.
  mkModuleTree =
    base:
    let
      entries = builtins.readDir base;
      stripExt = n: if lib.hasSuffix ".nix" n then lib.removeSuffix ".nix" n else n;

      mkDirTree =
        dirPath:
        let
          dirEntries = builtins.readDir dirPath;
          hasDefault = dirEntries ? "default.nix";
          children = lib.filterAttrs (_: v: v != null) (
            lib.mapAttrs' (n: kind: {
              name = stripExt n;
              value =
                if kind == "regular" && lib.hasSuffix ".nix" n && n != "default.nix" then
                  dirPath + "/${n}"
                else if kind == "directory" then
                  mkDirTree (dirPath + "/${n}")
                else
                  null;
            }) dirEntries
          );
        in
        if hasDefault then children // { default = dirPath + "/default.nix"; } else children;

      files = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs' (name: kind: {
          name = stripExt name;
          value = if kind == "regular" && lib.hasSuffix ".nix" name then base + "/${name}" else null;
        }) entries
      );

      dirs = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs' (name: kind: {
          name = name;
          value = if kind == "directory" then mkDirTree (base + "/${name}") else null;
        }) entries
      );

      merged =
        let
          keys = lib.unique (lib.attrNames files ++ lib.attrNames dirs);
        in
        lib.genAttrs keys (
          k:
          let
            hasFile = builtins.hasAttr k files;
            hasDir = builtins.hasAttr k dirs;
          in
          if hasFile && hasDir then
            (dirs.${k} // { file = files.${k}; })
          else if hasFile then
            files.${k}
          else
            dirs.${k}
        );
    in
    merged;

  # ---------------------------------------------------------------------------
  # User normalization & home-manager module resolution (shared by builders)
  # ---------------------------------------------------------------------------

  # Normalize a user entry (string or attrset) into a canonical spec.
  normalizeUser =
    u:
    if builtins.isString u then
      {
        name = u;
        groups = [ ];
        packages = [ ];
        sshKey = "";
        homeManager = {
          enable = true;
          module = "auto";
        };
      }
    else
      {
        name = u.name;
        groups = u.groups or u.extraGroups or [ ];
        packages = u.packages or [ ];
        sshKey = u.sshKey or "";
        homeManager =
          u.homeManager or {
            enable = true;
            module = "auto";
          };
      };

  # Convert a user list into an attrset keyed by user name.
  usersToAttrs =
    users: lib.listToAttrs (map (u: lib.nameValuePair u.name u) (map normalizeUser users));

  # Load normalized users for a given host (by name) from nixos/hosts/<host>/options.nix.
  getHostUsers =
    { flakeRoot, host }:
    usersToAttrs ((loadDeviceConfig (flakeRoot + "/nixos/hosts/${host}")).users or [ ]);

  # Collect all per-host per-user SSH keys:
  # userKeys = hostUtils.collectSshKeys { inherit flakeRoot; };
  # root.openssh.authorizedKeys.keys = with userKeys; [ archimedes.iamanaws goliath.iamanaws ];
  collectSshKeys =
    { flakeRoot }:
    let
      hostsDir = flakeRoot + "/nixos/hosts";
      hosts = dirNames hostsDir;
      mkHostKeys =
        host:
        lib.filterAttrs (_: k: k != "") (
          lib.mapAttrs (_: u: u.sshKey) (getHostUsers {
            inherit flakeRoot host;
          })
        );
    in
    lib.genAttrs hosts mkHostKeys;

  # Resolve a home-manager module path for a user.
  #
  # `os` is "nixos" or "darwin"; determines which OS-specific subdir to prefer.
  # `homeUsersRoot` is the path to `home/users`.
  # `hmModuleMode` is the value of `homeManager.module` (e.g. "auto", "nixos", "darwin", "nixos/pwnbox").
  mkHmModulePath =
    {
      homeUsersRoot,
      os,
      user,
      hmModuleMode,
    }:
    let
      osPath = homeUsersRoot + "/${user}/${os}";
      defaultPath = homeUsersRoot + "/${user}";
      relPathFor = rel: homeUsersRoot + "/${user}/${rel}";
      otherOs = if os == "nixos" then "darwin" else "nixos";

      pickAuto =
        if builtins.pathExists osPath then
          osPath
        else if builtins.pathExists defaultPath then
          defaultPath
        else
          throw "No home-manager module found for user '${user}'. Expected ${toString osPath} or ${toString defaultPath}.";

      requirePath = p: msg: if builtins.pathExists p then p else throw msg;
    in
    if hmModuleMode == "auto" then
      pickAuto
    else if hmModuleMode == os then
      requirePath osPath "Missing ${toString osPath} for user '${user}'."
    else if hmModuleMode == "default" then
      requirePath defaultPath "Missing ${toString defaultPath} for user '${user}'."
    else if hmModuleMode == otherOs then
      throw "homeManager.module = \"${otherOs}\" is not valid for ${os} hosts (user '${user}')."
    else if lib.hasPrefix "${os}/" hmModuleMode then
      requirePath (relPathFor hmModuleMode) "Missing ${toString (relPathFor hmModuleMode)} for user '${user}' (requested homeManager.module = \"${hmModuleMode}\")."
    else
      throw "Invalid homeManager.module '${hmModuleMode}' for user '${user}'.";

  # Build `outputsForHM` ensuring `overlays` is always present.
  mkOutputsForHM =
    { outputs, inputs }:
    let
      flakeOverlays = import (inputs.self + /overlays) { inherit (inputs) nur; };
    in
    outputs // { overlays = outputs.overlays or flakeOverlays; };

  mkHostContext =
    device:
    let
      system = device.system or "";
      compositors = device.compositors or [ ];
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
    in
    {
      inherit compositors isDarwin isLinux;
      isGraphical = isDarwin || (isLinux && compositors != [ ]);
      hyprland = lib.elem "hyprland" compositors;
      gnome = lib.elem "gnome" compositors;
    };

in
{
  inherit
    dirNames
    loadDeviceConfig
    loadHostDevices
    mkModuleTree
    normalizeUser
    usersToAttrs
    getHostUsers
    collectSshKeys
    mkHmModulePath
    mkOutputsForHM
    mkHostContext
    ;
}
