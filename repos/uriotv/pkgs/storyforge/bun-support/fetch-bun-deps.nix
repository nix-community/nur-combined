{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;

  invalidBunNixErr = ''
    Your supplied `bun.nix` dependencies file failed to evaluate.

    This is likely because the version of `bun2nix` you are using has changed and
    the `bun.nix` file has no schema stability guarantees between versions, and
    will simply change as needed since updating it is trivial.

    As a result, you should try regenerating your `bun.nix` file:

    ```sh
    bun2nix -o bun.nix
    ```
  '';

  # Registry authentication utilities

  # Extract URL from scope config (handles both string and object formats)
  extractUrl = cfg: if builtins.isString cfg then cfg else cfg.url or null;

  # Parse bunfig.toml for registry credentials
  parseBunfigCredentials =
    bunfigPath:
    if bunfigPath != null && builtins.pathExists bunfigPath then
      let
        bunfig = builtins.fromTOML (builtins.readFile bunfigPath);
        scopes = bunfig.install.scopes or { };
        extractToken = cfg: if builtins.isString cfg then null else cfg.token or null;
        scopeEntries = builtins.mapAttrs (_: cfg: {
          url = extractUrl cfg;
          token = extractToken cfg;
        }) scopes;
      in
      builtins.listToAttrs (
        builtins.filter (x: x.value != null) (
          builtins.map (
            name:
            let
              entry = scopeEntries.${name};
            in
            {
              name = entry.url;
              value = entry.token;
            }
          ) (builtins.attrNames scopeEntries)
        )
      )
    else
      { };

  # Parse .npmrc for registry credentials
  # Format: //<registry>/:_authToken=<token>
  parseNpmrcCredentials =
    npmrcPath:
    if npmrcPath != null && builtins.pathExists npmrcPath then
      let
        content = builtins.readFile npmrcPath;
        lines = builtins.filter builtins.isString (builtins.split "\n" content);
        # Parse a line like //npm.pkg.github.com/:_authToken=TOKEN
        parseLine =
          line:
          let
            match = builtins.match "^//([^/]+)/:_authToken=(.+)$" line;
          in
          if match != null then
            {
              url = "https://${builtins.elemAt match 0}";
              token = builtins.elemAt match 1;
            }
          else
            null;
        parsed = builtins.filter (x: x != null) (builtins.map parseLine lines);
      in
      builtins.listToAttrs (
        builtins.map (entry: {
          name = entry.url;
          value = entry.token;
        }) parsed
      )
    else
      { };

  # Get auth header for a URL by matching registry host
  getAuthHeader =
    credentials: url:
    let
      # Extract host from URL
      match = builtins.match "https?://([^/]+)/.*" url;
      host = if match != null then builtins.elemAt match 0 else null;
      # Find matching credential
      matchingUrls = builtins.filter (
        credUrl:
        let
          credMatch = builtins.match "https?://([^/]+).*" credUrl;
        in
        credMatch != null && builtins.elemAt credMatch 0 == host
      ) (builtins.attrNames credentials);
    in
    if builtins.length matchingUrls > 0 then credentials.${builtins.elemAt matchingUrls 0} else null;

  # Create an authenticated fetchurl wrapper
  makeRegistryFetchurl =
    fetchurl:
    {
      bunfigPath ? null,
      npmrcPath ? null,
    }:
    let
      bunfigCredentials = parseBunfigCredentials bunfigPath;
      npmrcCredentials = parseNpmrcCredentials npmrcPath;
      # Merge credentials (npmrc takes precedence)
      credentials = bunfigCredentials // npmrcCredentials;
    in
    # Wrapper for fetchurl that adds auth headers and preserves URL in passthru
    {
      url,
      ...
    }@args:
    let
      token = getAuthHeader credentials url;
      authArgs =
        if token != null then
          {
            curlOptsList = [
              "-H"
              "Authorization: Bearer ${token}"
            ];
          }
        else
          { };
      drv = fetchurl (args // authArgs);
    in
    # Preserve URL in passthru for registry extraction in build-package.nix
    drv
    // {
      passthru = (drv.passthru or { }) // {
        inherit url;
      };
    };
in
{
  options.perSystem = mkPerSystemOption {
    options.fetchBunDeps.function = mkOption {
      description = ''
        Bun cache creator function.

        Produces a file accurate, symlink farm recreation of bun's global install cache.

        See [bun's cache docs](https://github.com/oven-sh/bun/blob/642d04b9f2296ae41d842acdf120382c765e632e/docs/install/cache.md#L24)
        for more information.
      '';
      type = types.functionTo types.package;
    };
  };

  config.perSystem =
    { pkgs, config, ... }:
    {
      fetchBunDeps.function =
        {
          bunNix,
          bunfigPath ? null,
          npmrcPath ? null,
          overrides ? { },
          ...
        }@args:
        let
          attrIsBunPkg = _: value: lib.isStorePath value;

          # Create authenticated fetchurl wrapper
          fetchurlWithAuth = makeRegistryFetchurl pkgs.fetchurl {
            inherit bunfigPath npmrcPath;
          };

          withErrCtx = builtins.addErrorContext invalidBunNixErr (
            pkgs.callPackage bunNix {
              fetchurl = fetchurlWithAuth;
            }
          );

          packages = lib.filterAttrs attrIsBunPkg withErrCtx;

          buildPackage = config.fetchBunDeps.buildPackage args;
          overridePackage = config.fetchBunDeps.overridePackage args;
        in

        assert lib.asserts.assertEachOneOf "overrides" (builtins.attrNames overrides) (
          builtins.attrNames packages
        );

        assert lib.assertMsg (builtins.all builtins.isFunction (builtins.attrValues overrides))
          "All attr values of `overrides` must be functions taking the old, unoverrided package and returning the new source.";

        pkgs.symlinkJoin {
          name = "bun-cache";
          paths = lib.pipe packages [
            (builtins.mapAttrs overridePackage)
            (builtins.mapAttrs buildPackage)
            builtins.attrValues
          ];
        };
    };
}
