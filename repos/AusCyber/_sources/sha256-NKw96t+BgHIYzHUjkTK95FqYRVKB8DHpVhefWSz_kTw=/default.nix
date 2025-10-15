# An implementation of Flakes in Nix language, useful for validating and
# specifying flake behaviour, evaluating flakes in unintended ways, and
# otherwise experimenting with them. It also allows evaluating flakes on
# non-flake-compatible Nix implementations.
#
# Given a source tree containing a 'flake.nix' and 'flake.lock' file,
# flake-compat fetches the flake inputs and calls the flake's 'outputs'
# function. It then returns an attrset containing 'defaultNix' (to be used in
# 'default.nix'), 'shellNix' (to be used in 'shell.nix').

{
  src,
  # Whether to (slowly) copy the entire source tree into the Nix store.
  # Disabling this improves evaluation speed immensely at the cost of
  # deleting the alleged purity gained by flakes: no longer obeying
  # gitignores.
  #
  # It is recommended anyway to do explicit file filtering using e.g.
  # lib.filesets in nixpkgs rather than copying entire directories, since it
  # improves evaluation performance and reduces spurious rebuilds.
  copySourceTreeToStore ? true,
  # Whether to use native builtins.fetchTree. In the future, this *might*
  # become `builtins ? fetchTree`, but Lix in versions prior to 2.93
  # (https://gerrit.lix.systems/c/lix/+/2399) had a fetchTree that throws in an
  # uncatchable way if flakes are disabled.
  #
  # At a broader level, we are *to some extent* documenting
  # builtins.fetchTree's oddities by implementing it in this project and it
  # would not be ideal to lose that.
  useBuiltinsFetchTree ? false,
  system ? builtins.currentSystem or "unknown-system",
}:

let

  lockFilePath = src + "/flake.lock";

  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);

  optionalAttrs = cond: attrs: if cond then attrs else { };
  copyAttrIfPresent =
    name: attrs: if builtins.hasAttr name attrs then { "${name}" = attrs."${name}"; } else { };
  maybeNarHash = attrs: optionalAttrs (attrs ? narHash) { sha256 = attrs.narHash; };

  # Note [fetchurl of tarball files in recursive hash mode]:
  # We have to use a custom fetchurl function here so that we can specify
  # outputHashMode. The hash we get from the lock file is using recursive
  # ingestion even though it’s not unpacked. So builtins.fetchurl and import
  # <nix/fetchurl.nix> are insufficient.
  #
  # See Note [Recursive hashing of file inputs] in lix/libfetchers/tarball.cc
  # for details on hash modes of flake inputs and why they are always recursive.
  # https://git.lix.systems/lix-project/lix/src/b22bee91f5a0360b93d1e1ad71fbfd2ff432bf6c/lix/libfetchers/tarball.cc#L18-L49
  # See also: https://git.lix.systems/lix-project/lix/issues/750
  #
  # Note that the return value from fetchurlInner will be a derivation and not
  # a path as builtins.fetchTree is, which will cause it to appear in inputDrvs
  # rather than inputSrcs in derivations it appears in. We have to fix this
  # string context to be a path with import-from-derivation using
  # builtins.path.
  fetchurl =
    { url, sha256 }:
    # Force an input-from-derivation point to change the path from inputDrvs to
    # inputSrcs: the context needs to be a path rather than a derivation to
    # match fetchTree behaviour.
    #
    # This is, needless to say, sort of gross, but it does not have any real
    # performance consequence to use builtins.path as an identity function.
    builtins.path {
      path = fetchurlInner { inherit url sha256; };
      name = "source";
      # This is the default, but let's be explicit.
      recursive = true;
    };
  fetchurlInner =
    { url, sha256 }:
    derivation {
      builder = "builtin:fetchurl";

      name = "source";
      inherit url;

      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      executable = false;
      unpack = false;

      system = "builtin";

      # No need to double the amount of network traffic
      preferLocalBuild = true;

      impureEnvVars = [
        # We borrow these environment variables from the caller to allow
        # easy proxy configuration.  This is impure, but a fixed-output
        # derivation like fetchurl is allowed to do so since its result is
        # by definition pure.
        "http_proxy"
        "https_proxy"
        "ftp_proxy"
        "all_proxy"
        "no_proxy"
      ];

      # To make "nix-prefetch-url" work.
      urls = [ url ];
    };

  fetchTree =
    info:
    if useBuiltinsFetchTree then
      builtins.fetchTree info
    else
      fetchTreeInner info // copyAttrIfPresent "narHash" info;

  fetchTreeInner =
    info:
    if info.type == "github" then
      {
        outPath = fetchTarball (
          {
            url = "https://api.${info.host or "github.com"}/repos/${info.owner}/${info.repo}/tarball/${info.rev}";
          }
          // maybeNarHash info
        );
        rev = info.rev;
        shortRev = builtins.substring 0 7 info.rev;
        lastModified = info.lastModified;
        lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
      }
    else if info.type == "git" then
      {
        outPath = builtins.fetchGit (
          {
            url = info.url;
          }
          // copyAttrIfPresent "rev" info
          // copyAttrIfPresent "ref" info
          // copyAttrIfPresent "submodules" info
        );
        lastModified = info.lastModified;
        lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
        revCount = info.revCount or 0;
      }
      // optionalAttrs (info ? rev) {
        inherit (info) rev;
        shortRev = builtins.substring 0 7 info.rev;
      }
    else if info.type == "path" then
      {
        outPath =
          if copySourceTreeToStore then
            builtins.path (
              {
                inherit (info) path;
                name = "source";
              }
              // maybeNarHash info
            )
          else
            info.path;
      }
    else if info.type == "tarball" then
      {
        outPath = fetchTarball ({ inherit (info) url; } // maybeNarHash info);
      }
    else if info.type == "gitlab" then
      {
        inherit (info) rev lastModified;
        outPath = fetchTarball (
          {
            url = "https://${info.host or "gitlab.com"}/api/v4/projects/${info.owner}%2F${info.repo}/repository/archive.tar.gz?sha=${info.rev}";
          }
          // maybeNarHash info
        );
        shortRev = builtins.substring 0 7 info.rev;
      }
    else if info.type == "sourcehut" then
      {
        inherit (info) rev lastModified;
        outPath = fetchTarball (
          {
            url = "https://${info.host or "git.sr.ht"}/${info.owner}/${info.repo}/archive/${info.rev}.tar.gz";
          }
          // maybeNarHash info
        );
        shortRev = builtins.substring 0 7 info.rev;
      }
    else if info.type == "file" then
      {
        outPath =
          if
            builtins.substring 0 7 info.url == "http://" || builtins.substring 0 8 info.url == "https://"
          then
            fetchurl {
              inherit (info) url;
              sha256 = info.narHash;
            }
          else if builtins.substring 0 7 info.url == "file://" then
            builtins.path (
              {
                # FIXME(jade): this probably should be called source? needs a test
                path = builtins.substring 7 (-1) info.url;
              }
              // maybeNarHash info
            )
          else
            throw "can't support url scheme of flake input with url '${info.url}'";
      }
    else
      # FIXME: add Mercurial inputs.
      throw "flake input has unsupported input type '${info.type}'";

  callFlake4 =
    flakeSrc: locks:
    let
      flake = import (flakeSrc + "/flake.nix");

      inputs = builtins.mapAttrs (
        n: v:
        if v.flake or true then
          callFlake4 (fetchTree (v.locked // v.info)) v.inputs
        else
          fetchTree (v.locked // v.info)
      ) locks;

      outputs = flakeSrc // (flake.outputs (inputs // { self = outputs; }));
    in
    assert flake.edition == 201909;
    outputs;

  callLocklessFlake =
    flakeSrc:
    let
      flake = import (flakeSrc + "/flake.nix");
      outputs = flakeSrc // (flake.outputs ({ self = outputs; }));
    in
    outputs;

  rootTreeFromPathish =
    tree:
    let
      # Try to clean the source tree by using fetchGit, if this source
      # tree is a valid git repository.
      tryFetchGit =
        tree:
        if isGit && !isShallow then
          let
            res = builtins.fetchGit tree;
          in
          if res.rev == "0000000000000000000000000000000000000000" then
            removeAttrs res [
              "rev"
              "shortRev"
            ]
          else
            res
        else
          {
            outPath =
              # Massage `tree` into a store path.
              if builtins.isPath tree then
                if
                  dirOf (toString tree) == builtins.storeDir
                  # `builtins.storePath` is not available in pure-eval mode.
                  && builtins ? currentSystem
                then
                  # If it's already a store path, don't copy it again.
                  builtins.storePath tree
                else
                  builtins.path {
                    path = tree;
                    name = "source";
                  }
              else
                tree;
          };
      # NB git worktrees have a file for .git, so we don't check the type of .git
      isGit = builtins.pathExists (tree + "/.git");
      isShallow = builtins.pathExists (tree + "/.git/shallow");

    in
    {
      lastModified = 0;
      lastModifiedDate = formatSecondsSinceEpoch 0;
    }
    // (if tree ? outPath then tree else tryFetchGit tree);

  rootSrc = rootTreeFromPathish (
    if copySourceTreeToStore then
      src
    else
      # *hacker voice*: it's definitely a store path, I promise (actually a
      # nixlang path value, likely not pointing at the store).
      { outPath = src; }
  );

  # Format number of seconds in the Unix epoch as %Y%m%d%H%M%S.
  formatSecondsSinceEpoch =
    t:
    let
      rem = x: y: x - x / y * y;
      days = t / 86400;
      secondsInDay = rem t 86400;
      hours = secondsInDay / 3600;
      minutes = (rem secondsInDay 3600) / 60;
      seconds = rem t 60;

      # Courtesy of https://stackoverflow.com/a/32158604.
      z = days + 719468;
      era = (if z >= 0 then z else z - 146096) / 146097;
      doe = z - era * 146097;
      yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
      y = yoe + era * 400;
      doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
      mp = (5 * doy + 2) / 153;
      d = doy - (153 * mp + 2) / 5 + 1;
      m = mp + (if mp < 10 then 3 else -9);
      y' = y + (if m <= 2 then 1 else 0);

      pad = s: if builtins.stringLength s < 2 then "0" + s else s;
    in
    "${toString y'}${pad (toString m)}${pad (toString d)}${pad (toString hours)}${pad (toString minutes)}${pad (toString seconds)}";

  allNodes = builtins.mapAttrs (
    key: node:
    let
      sourceInfo =
        if key == lockFile.root then
          rootSrc
        else
          fetchTree (node.info or { } // removeAttrs node.locked [ "dir" ]);

      subdir = if key == lockFile.root then "" else node.locked.dir or "";

      outPath = sourceInfo + ((if subdir == "" then "" else "/") + subdir);

      flake = import (outPath + "/flake.nix");

      inputs = builtins.mapAttrs (inputName: inputSpec: allNodes.${resolveInput inputSpec}) (
        node.inputs or { }
      );

      # Resolve a input spec into a node name. An input spec is
      # either a node name, or a 'follows' path from the root
      # node.
      resolveInput =
        inputSpec: if builtins.isList inputSpec then getInputByPath lockFile.root inputSpec else inputSpec;

      # Follow an input path (e.g. ["dwarffs" "nixpkgs"]) from the
      # root node, returning the final node.
      getInputByPath =
        nodeName: path:
        if path == [ ] then
          nodeName
        else
          getInputByPath
            # Since this could be a 'follows' input, call resolveInput.
            (resolveInput lockFile.nodes.${nodeName}.inputs.${builtins.head path})
            (builtins.tail path);

      outputs = flake.outputs (inputs // { self = result; });

      result =
        outputs
        # We add the sourceInfo attribute for its metadata, as they are
        # relevant metadata for the flake. However, the outPath of the
        # sourceInfo does not necessarily match the outPath of the flake,
        # as the flake may be in a subdirectory of a source.
        # This is shadowed in the next //
        // sourceInfo
        // {
          # This shadows the sourceInfo.outPath
          inherit outPath;

          inherit inputs;
          inherit outputs;
          inherit sourceInfo;
          _type = "flake";
        };

    in
    if node.flake or true then
      assert builtins.isFunction flake.outputs;
      result
    else
      sourceInfo
  ) lockFile.nodes;

  result =
    if !(builtins.pathExists lockFilePath) then
      callLocklessFlake rootSrc
    else if lockFile.version == 4 then
      callFlake4 rootSrc (lockFile.inputs)
    else if lockFile.version >= 5 && lockFile.version <= 7 then
      allNodes.${lockFile.root}
    else
      throw "lock file '${lockFilePath}' has unsupported version ${toString lockFile.version}";

in
rec {
  inputs = result.inputs or { } // {
    self = result;
  };

  outputs = result;

  defaultNix =
    (builtins.removeAttrs result [ "__functor" ])
    // (
      if result ? defaultPackage.${system} then { default = result.defaultPackage.${system}; } else { }
    )
    // (
      if result ? packages.${system}.default then
        { default = result.packages.${system}.default; }
      else
        { }
    );

  shellNix =
    defaultNix
    // (if result ? devShell.${system} then { default = result.devShell.${system}; } else { })
    // (
      if result ? devShells.${system}.default then
        { default = result.devShells.${system}.default; }
      else
        { }
    );
}
