{ lib }:
let
  # List only directories under a given path (stable + matches how flake.nix enumerates hosts).
  dirNames = dir: lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir));

  # Discover `<backend>/hosts/<hostname>` trees and normalize their host data.
  # The directory layout and each host's options.nix remain the source of truth;
  # adding a backend-specific system builder is handled separately in flake.nix.
  discoverHostRegistry =
    flakeRoot:
    let
      rootEntries = builtins.readDir flakeRoot;
      backends = lib.attrNames (
        lib.filterAttrs (
          name: kind: kind == "directory" && builtins.pathExists (flakeRoot + "/${name}/hosts")
        ) rootEntries
      );

      mkHost =
        backend: name:
        let
          path = flakeRoot + "/${backend}/hosts/${name}";
          # Evaluate the same schema used by system modules before selecting
          # imports, so standalone homes and system builders share its defaults.
          device =
            (lib.evalModules {
              modules = [
                ../nixos/modules/device-options.nix
                (path + "/options.nix")
                { device.hostname = lib.mkDefault name; }
              ];
            }).config.device;
        in
        {
          inherit
            backend
            device
            name
            path
            ;
          inherit (device) users;
          hostConfig = mkHostContext device;
        };

      byBackend = lib.genAttrs backends (
        backend:
        lib.filterAttrs (_: host: host.device.enable) (
          lib.genAttrs (dirNames (flakeRoot + "/${backend}/hosts")) (mkHost backend)
        )
      );
    in
    {
      inherit backends byBackend;
      all = lib.concatMap (backend: lib.attrValues byBackend.${backend}) backends;
    };

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
          inherit name;
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

  # Collect SSH keys from the same normalized records consumed by the builders.
  collectSshKeys =
    hostRegistry:
    lib.mapAttrs (
      _: host:
      lib.listToAttrs (
        map (user: lib.nameValuePair user.name user.sshKey) (
          lib.filter (user: user.sshKey != "") host.users
        )
      )
    ) (hostRegistry.byBackend.nixos or { });

  # Resolve a home-manager module path for a user.
  #
  # `backend` determines which backend-specific subdir to prefer.
  # `homeUsersRoot` is the path to `home/users`.
  # `hmModuleMode` is the value of `homeManager.module` (e.g. "auto", "nixos", "nixos/pwnbox").
  mkHmModulePath =
    {
      backend,
      homeUsersRoot,
      knownBackends ? [
        "nixos"
        "darwin"
      ],
      user,
      hmModuleMode,
    }:
    let
      backendPath = homeUsersRoot + "/${user}/${backend}";
      defaultPath = homeUsersRoot + "/${user}";
      relPathFor = rel: homeUsersRoot + "/${user}/${rel}";
      isForeignBackendMode = lib.any (
        candidate:
        candidate != backend && (hmModuleMode == candidate || lib.hasPrefix "${candidate}/" hmModuleMode)
      ) knownBackends;

      pickAuto =
        if builtins.pathExists backendPath then
          backendPath
        else if builtins.pathExists defaultPath then
          defaultPath
        else
          throw "No home-manager module found for user '${user}'. Expected ${toString backendPath} or ${toString defaultPath}.";

      requirePath = p: msg: if builtins.pathExists p then p else throw msg;
    in
    if hmModuleMode == "auto" then
      pickAuto
    else if hmModuleMode == backend then
      requirePath backendPath "Missing ${toString backendPath} for user '${user}'."
    else if hmModuleMode == "default" then
      requirePath defaultPath "Missing ${toString defaultPath} for user '${user}'."
    else if lib.hasPrefix "${backend}/" hmModuleMode then
      requirePath (relPathFor hmModuleMode) "Missing ${toString (relPathFor hmModuleMode)} for user '${user}' (requested homeManager.module = \"${hmModuleMode}\")."
    else if isForeignBackendMode then
      throw "homeManager.module = \"${hmModuleMode}\" is not valid for ${backend} hosts (user '${user}')."
    else
      throw "Invalid homeManager.module '${hmModuleMode}' for user '${user}'.";

  mkHostContext =
    device:
    let
      inherit (device) system compositors;
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
    in
    {
      inherit
        device
        compositors
        isDarwin
        isLinux
        ;
      isGraphical = isDarwin || (isLinux && compositors != [ ]);
      hyprland = lib.elem "hyprland" compositors;
      gnome = lib.elem "gnome" compositors;
    };

in
{
  inherit
    dirNames
    discoverHostRegistry
    mkModuleTree
    collectSshKeys
    mkHmModulePath
    mkHostContext
    ;
}
