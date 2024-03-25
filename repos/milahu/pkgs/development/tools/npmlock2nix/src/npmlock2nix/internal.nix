{ lib
, nodejs
, jq
, openssl
, coreutils
, stdenv
, mkShell
, fetchurl
, writeText
, writeShellScript
, runCommand
, fetchFromGitHub
, pnpm-install-only ? null
, nodejs-hide-symlinks ? null
}:

rec {
  default_nodejs = nodejs;

  ## helper functions that allow users to define common source override mechanism

  # no-op function that serves as a marker in the `sourceOverrides`
  # code. If an override is set the source is passed through the
  # entire override mechanism which does, as a side effect, patch the
  # shebangs in the source tarball.
  packageRequirePatchShebangs = sourceInfo: drv: drv;

  # builtins.fetchGit wrapper that ensures compatibility with Nix 2.3 and Nix 2.4
  # Type: Attrset -> Path
  fetchGitWrapped =
    let
      is24OrNewer = lib.versionAtLeast builtins.nixVersion "2.4";
    in
    if is24OrNewer then
    # remove the now unsupported / insufficient `ref` paramter
      args: builtins.fetchGit (builtins.removeAttrs args [ "ref" ])
    else
    # for 2.3 (and older?) we remove the unsupported `allRefs` parameter
      args: builtins.fetchGit (builtins.removeAttrs args [ "allRefs" ])
  ;

  # Description: Custom throw function that ensures our error messages have a common prefix.
  # Type: String -> Throw
  throw = str: builtins.throw "[npmlock2nix] ${str}";

  # Description: Checks if a string looks like a valid github reference
  # Type: String -> Boolean
  isGitHubRef = str:
    # github:owner/repo
    if builtins.substring 0 7 str == "github:" then true else
    let
      parts = builtins.split "[:#/@]" str;
      partsLen = builtins.length parts;
      # https://github.com/npm/hosted-git-info/blob/main/lib/from-url.js
      # used by https://github.com/npm/cli
      # look for github shorthand inputs, such as npm/cli
      isGitHubShorthand = str:
        let
          # example: stringIndexOf "abbbc" "b" == 2
          # https://github.com/milahu/nix-for-javascript-developers/blob/patch-1
          # no: builtins.match does not support the non-greedy quantifier ".*?"
          #stringIndexOf = string: needle:
          #  let matches = builtins.match ("^(.*?)" + (lib.strings.escapeRegex needle) + ".*") string; in
          #  if matches == null then -1 else builtins.stringLength (builtins.elemAt matches 0);
          stringIndexOf = string: needle:
            let parts = builtins.split needle string; in
            if builtins.length parts == 1 then -1
            else builtins.stringLength (builtins.elemAt parts 0);

          # example: substringEnd 2 "abcde" == "cde"
          substringEnd = start: string:
            let length = builtins.stringLength string; in
            builtins.substring start length string;

          # example: stringIndexOfFirstSpace "a \n\tb c" == 1
          stringIndexOfFirstSpace = string:
            let matches = builtins.match "([^[:space:]]*)([[:space:]]).*" string; in
            if matches == null then -1
            else builtins.stringLength (builtins.elemAt matches 0);

          # const firstHash = arg.indexOf('#')
          firstHash = stringIndexOf str "#";
          firstSlash = stringIndexOf str "/";
          # const secondSlash = arg.indexOf('/', firstSlash + 1)
          secondSlash = stringIndexOf (substringEnd (firstSlash + 1) str) "/";
          firstColon = stringIndexOf str ":";
          # const firstSpace = /\s/.exec(arg)
          firstSpace = stringIndexOfFirstSpace str;
          firstAt = stringIndexOf str "@";

          spaceOnlyAfterHash = (firstSpace == -1) || (firstHash > -1 && firstSpace > firstHash);
          atOnlyAfterHash = firstAt == -1 || (firstHash > -1 && firstAt > firstHash);
          colonOnlyAfterHash = firstColon == -1 || (firstHash > -1 && firstColon > firstHash);
          secondSlashOnlyAfterHash = secondSlash == -1 || (firstHash > -1 && secondSlash > firstHash);
          hasSlash = firstSlash > 0;
          # if a # is found, what we really want to know is that the character
          # immediately before # is not a /
          # const doesNotEndWithSlash = firstHash > -1 ? arg[firstHash - 1] !== '/' : !arg.endsWith('/')
          doesNotEndWithSlash = if firstHash > -1 then (builtins.substring (firstHash - 1) 1 != "/") else (builtins.match ".*/" str == null);
          # const doesNotStartWithDot = !arg.startsWith('.')
          doesNotStartWithDot = (builtins.substring 0 1 str) != ".";
        in (
          spaceOnlyAfterHash && hasSlash && doesNotEndWithSlash &&
          doesNotStartWithDot && atOnlyAfterHash && colonOnlyAfterHash &&
          secondSlashOnlyAfterHash
        );
    in
    if isGitHubShorthand str then true else
    # TODO why these numbers? use a better string parser?
    if partsLen == 7 || partsLen == 9 || partsLen == 15
    then
      (
        ((builtins.elemAt parts 0) == "github") ||
        ((builtins.elemAt parts 2) == "github.com") ||
        ((builtins.elemAt parts 2) == "github") ||
        (partsLen > 7 && (builtins.elemAt parts 8) == "github.com")
      )
    else false;

  # Description: Checks if a string looks like a valid github
  # reference who do not have a rev. You shouldn't find any of those
  # in a "resolved" field. It's however possible to find them in a
  # "dependencies" part of a package.
  # Type: String -> Boolean
  isGitHubRefWithoutRev = str:
    let
      parts = builtins.split "[:#/@]" str;
      partsLen = builtins.length parts;
    in
    partsLen == 5 && builtins.elemAt parts 0 == "github";

  # Description: Takes a string of the format
  # "git+ssh://git@github.com/owner/repo.git#revision",
  # "git@github.com/owner/repo.git#revision" or
  # github:owner/repo#revision and returns an attribute set.
  # Type: String -> { org, repo, rev }
  parseGitHubRef = str:
    let
      parts = builtins.split "[:#/]" str;
      # Parse a string of the format "git+ssh://git@github.com/owner/repo.git#revision"
      ghGitSshFormatParser = str:
        let
          repoWithGitSuffix = builtins.elemAt parts 10;
        in
        {
          inherit parts;
          org = builtins.elemAt parts 8;
          repo = builtins.substring 0 ((builtins.stringLength repoWithGitSuffix) - 4) repoWithGitSuffix;
          rev = builtins.elemAt parts 12;
        };
      # Parse a string of the format github:owner/repo#revision
      ghShortnameParser = str: {
        inherit parts;
        org = builtins.elemAt parts 2;
        repo = builtins.elemAt parts 4;
        rev = builtins.elemAt parts 6;
      };
      # Parse a string of the format owner@github:owner/repo#revision
      ghGitRefParser = str: {
        inherit parts;
        org = builtins.elemAt parts 2;
        repo = builtins.elemAt parts 4;
        rev = builtins.elemAt parts 6;
      };
      partLen = builtins.length parts;
    in
    assert !((partLen == 13) || (partLen == 7)) ->
      throw "failed to parse GitHub reference `${str}`. Expected a string of format `git+ssh://git@github.org/owner/repo.git#revision or `github:owner/repo#revision`";
    if (partLen == 13)
    then ghGitSshFormatParser str
    else
      if (builtins.elemAt parts 0) == "github"
      then ghShortnameParser str
      else ghGitRefParser str;

  # Description: Takes an attribute set describing a git dependency and returns
  # a .tgz of the repository as store path. If the attribute hash contains a
  # hash attribute it will provide the value to `fetchFromGitHub` which will
  # also work in restricted evaluation.
  # Type: { name :: String , org :: String, repo :: String, rev :: String, ref :: String, hash :: String, sourceOptions :: Set }
  #       -> drv
  buildTgzFromGitHub = { name, org, repo, rev, ref, hash ? null, sourceOptions ? { } }:
    let
      src =
        if hash != null then
          fetchFromGitHub
            {
              owner = org;
              inherit repo;
              inherit rev;
              sha256 = hash; # FIXME: what if sha3?
            } else
          fetchGitWrapped {
            url = "https://github.com/${org}/${repo}";
            inherit rev ref;
            allRefs = true;
          };

      sourceInfo = {
        github = { inherit org repo rev ref; };
      };
      drv = packTgz sourceOptions name ref src;
    in
    if sourceOptions ? sourceOverrides.${name}
    then sourceOptions.sourceOverrides.${name} sourceInfo drv
    else drv;

  # Description: Packs a source directory into a .tgz tar archive. If the
  # source is an archive, it gets unpacked first.
  # Type: Path -> String -> String -> Path -> Path
  packTgz = sourceOptions: pname: version: src: stdenv.mkDerivation (
    let
      preInstallLinks = writeShellScript "preInstallLinks" ''
        # preinstalled.links is a space separated text file in the
        # form of:
        # $symlink-target $symlink-location
        for link in "$(<preinstalled.links)"; do
          if [ ! -z "$link" ]; then
            target="$(echo "$link" | cut -d ' ' -f 1)"
            location="$(echo "$link" | cut -d ' ' -f 2)"
            mkdir -p "$(dirname "$location")"
            ln -sf "$target" "$location"
          fi
        done
      '';
    in
    rec {
      name = lib.strings.sanitizeDerivationName "${pname}-${version}" + (if sourceOptions.symlinkNodeModules then "" else ".tgz");
      id = "id_" + (builtins.replaceStrings [ "-" "." ] [ "_" "_" ] name);

      phases = "unpackPhase patchPhase installPhase";

      inherit src;
      sourceRoot = "package";
      outputs = [ "out" ] ++ (if sourceOptions.symlinkNodeModules then [ ] else [ "hash" ]);
      nativeBuildInputs = [ jq openssl ];

      propagatedBuildInputs = [
        sourceOptions.nodejs
      ];

      # chmod -R +w $sourceRoot
      #   make the source writable
      # chmod -R +X $sourceRoot
      #   fix permissions of directories
      #   example: /nix/store/jb1wi55v5z2gzx2rjma0v5323fij6wjp-pngjs-6.0.0.tgz
      #     lib/ has mode 0444 but should be 0555
      #     fixed by "chmod -R +X ."
      unpackPhase = ''
        runHook preUnpack
        mkdir -p ${sourceRoot}
        if [ -d $src ]; then
          cp -RT --reflink=auto $src $sourceRoot
        fi
        if [ -f $src ]; then
          tar --no-same-owner --no-same-permissions --warning=no-unknown-keyword --warning=no-timestamp --delay-directory-restore --strip-components=1 -xf $src -C $sourceRoot
        fi
        chmod -R +wX $sourceRoot
        runHook postUnpack
      '';

      installPhase = ''
        function prepare_links_for_npm_preinstall() {
          find . -type l -exec readlink -nf "{}" \; -exec echo " {}" \; -exec false {} \+ > preinstalled.links || {
            cp -p ${preInstallLinks} npm-preinstall-links.sh
            jq -r '.scripts.preinstall as $preinstall | .scripts.preinstall = "./npm-preinstall-links.sh;" + $preinstall' \
             package.json > package.json.tmp && mv package.json.tmp package.json
          }
        }

        function patch_node_package_bin() {
          for bin in $(jq -r '.bin | (.[]?, (select(.|type=="string")|.))' package.json); do
            if [ -f $bin ]; then
              chmod 755 $bin
              patchShebangs $bin
            fi
          done
          if [[ -d node_modules ]]; then
              # Patching shebangs of the bundled dependencies
              patchShebangs node_modules
          fi
        }

        prepare_links_for_npm_preinstall
        patch_node_package_bin

        runHook preInstall
        ${
          if sourceOptions.symlinkNodeModules then ''
            cp -r . $out
          '' else ''
            tar -C . -czf $out ./
            echo sha512-$(openssl dgst -sha512 -binary $out | openssl base64 -A) > $hash
          ''
        }
        runHook postInstall
      '';
    }
  );

  # Description: Replaces the `resolved` field of a dependency with a
  # prefetched version from the Nix store. Patches specified with sourceOverrides
  # will be applied, in which case the `integrity` attribute is set to `null`,
  # in order to be recomputer later
  # Type: { sourceOverrides :: Fn, nodejs :: Package } -> String -> String -> String -> String -> { resolved :: Path, integrity :: String }
  makeUrlSource = sourceOptions: name: version: resolved: integrity:
    let
      sourceOverrides = sourceOptions.sourceOverrides;
      src-packed = fetchurl {
        # Npm strips the query strings when opening a "file://.*" name.
        # We need to make sure we strip the query string before adding
        # the file to the store.
        name = builtins.elemAt (lib.splitString "?" (builtins.baseNameOf resolved)) 0;
        url = resolved;
        hash = integrity;
      };
      src =
        if sourceOptions.symlinkNodeModules
        #then (builtins.trace "npmlock2nix: unpacking source: ${src-packed}") unpackNpmTgz src-packed
        then unpackNpmTgz src-packed
        else src-packed;
      sourceInfo = {
        version = version;
      };
      drv = packTgz sourceOptions name version src;
      tgz = (
        # If we have modification to this source, unpack the tgz, apply the
        # patches and repack the tgz
        if sourceOverrides ? ${name} then
          sourceOverrides.${name} sourceInfo drv
        else
          if sourceOverrides.buildRequirePatchShebangs or false then drv else src
      );
      newResolved = (
        if sourceOverrides ? ${name} then
        # If we have modification to this source, unpack the tgz, apply the
        # patches and repack the tgz
          sourceOverrides.${name} sourceInfo drv
        else
          if sourceOverrides.buildRequirePatchShebangs or false then drv else src
      );
    in
    {
      integrity = if sourceOptions.symlinkNodeModules then null else integrity;
      resolved = (if sourceOptions.symlinkNodeModules then "" else "file://") + (toString newResolved);
    } // lib.optionalAttrs (newResolved != src) {
      # Integrity was tampered with due to the source attributes, so it needs
      # to be recalculated, which is done in the node_modules builder
      integrity = null;
    } // lib.optionalAttrs sourceOptions.symlinkNodeModules {
      # package is unpacked, so it has no file integrity
      integrity = null;
      # TODO? npm would remove { "integrity: "...", "name": "...", "version": "..." } and add { "link": true }
      # but pnpm-install-only does not need that (?)
      #name = null;
      #version = null;
      #link = true;
    };

  # TODO allow to override this builder in node_modules_attrs
  unpackNpmTgz = src:
    (stdenv.mkDerivation rec {
      name =
        let
          s = builtins.baseNameOf src;
          L = builtins.stringLength s;
          base = builtins.substring 33 (L - 33) s;
          baseNoExt = extLen: builtins.substring 33 (L - 33 - extLen) s;
          ext = builtins.substring (L - 4) L s;
        in
        if ext == ".tgz" then (baseNoExt 4) else base;
      inherit src;
      phases = "unpackPhase installPhase";
      # tar flags based on nixpkgs: pkgs/development/node-packages/node-env.nix
      # chmod -R +X $out
      #   fix permissions of directories
      #   example: /nix/store/jb1wi55v5z2gzx2rjma0v5323fij6wjp-pngjs-6.0.0.tgz
      #     lib/ has mode 0444 but should be 0555
      #     fixed by "chmod -R +X ."
      buildCommand = ''
        mkdir -p $out
        tar_args="tar --no-same-owner --no-same-permissions --warning=no-unknown-keyword --warning=no-timestamp --delay-directory-restore --strip-components=1 -xf $src -C $out"
        if ! $tar_args; then
          echo "error: unpacking failed: $tar_args"
          exit 1
        fi
        chmod -R +X $out
        patchShebangs $out | tail -n +2
      '';
    });

  # Description: Parses the lock file as json and returns an attribute set
  # Type: Path -> Set
  readPackageLikeFile = file:
    assert (builtins.typeOf file != "path" && builtins.typeOf file != "string") ->
      throw "file ${toString file} must be a path or string";
    let
      content = builtins.readFile file;
      json = builtins.fromJSON content;
    in
    assert
    builtins.typeOf json != "set" ->
    throw "The NPM lockfile must be a valid JSON object";
    # if a lockfile doesn't declare dependencies ensure that we have an empty
    # set. This makes the consuming code eaiser.
    if json ? dependencies then json else json // { dependencies = { }; };

  # fixme: this fails when the common value is null
  listsHaveCommonValue = list1: list2:
    # lib.lists.findFirst (v: builtins.elem v ["b" "c" "d"]) null ["a" "b" "c"] != null
    lib.lists.findFirst (v: builtins.elem v list1) null list2 != null;

  # Description: Patch a lockfile v2 package entry. It'll replace the
  # URL stored in the integrity field with nix store path.
  # spec :: {version :: String, resolved :: String, integrity :: String }.
  # Type: { version :: String, resolved :: String, integrity :: String }
  patchPackage = sourceOptions: raw_name: spec:
    assert (builtins.typeOf raw_name != "string") ->
      throw "Name of dependency ${toString raw_name} must be a string";
    assert !(spec ? resolved || (spec ? inBundle && spec.inBundle == true)) ->
      throw "Missing resolved field for dependency ${toString raw_name}";
    (
    if (spec ? optional && spec.optional == true) then
      # filter by cpu and os
      let removedSpec = spec // { version = ""; resolved = ""; integrity = ""; }; in
      if (spec ? cpu && spec ? os) then
        if (
          listsHaveCommonValue spec.cpu sourceOptions.nodeHostCpuNames &&
          listsHaveCommonValue spec.os sourceOptions.nodeHostOsNames
        )
        then (x: x) else (x: removedSpec)
      else
      if (spec ? cpu) then
        if listsHaveCommonValue spec.cpu sourceOptions.nodeHostCpuNames
        then (x: x) else (x: removedSpec)
      else
      if (spec ? os) then
        if listsHaveCommonValue spec.os sourceOptions.nodeHostOsNames
        then (x: x) else (x: removedSpec)
      else (x: x)
    else (x: x)
    )
    (
    let
      name = genericPackageName raw_name;
      defaultedIntegrity = if spec ? integrity then spec.integrity else null;
      # Relaxing dependencies version bounds: it could be a GitHub
      # ref, forcing NPM to checkout the remote repo to get the actual
      # version.
      # We already pinned everything through the "resolved", we can
      # relax those.
      patchDependencies = deps: lib.mapAttrs
        (_n: dep:
          if (
            isGitHubRef dep ||
            isGitHubRefWithoutRev dep ||
            # fix: npm ERR! code ENOTCACHED
            #   request to https://registry.npmjs.org/... failed:
            #   cache mode is 'only-if-cached' but no cached response is available.
            # similar issue: https://github.com/nix-community/npmlock2nix/issues/45
            dep == "latest"
          ) then "*" else
          dep
        ) deps;

      patchedResolved =
        if (!isGitHubRef spec.resolved)
        then makeUrlSource sourceOptions name spec.version spec.resolved defaultedIntegrity
        else
          let
            ghRef = parseGitHubRef spec.resolved;
            ghTgz = buildTgzFromGitHub {
              inherit name sourceOptions;
              inherit (ghRef) org repo rev;
              ref = ghRef.rev;
              hash = sourceOptions.sourceHashFunc { type = "github"; value = { inherit (ghRef) org repo rev; }; };
            };
          in
          {
            resolved = (if sourceOptions.symlinkNodeModules then "" else "file://") + (toString ghTgz);
            integrity = null;
          };
    in
    (builtins.removeAttrs spec [ "peerDependencies" ]) //
    lib.optionalAttrs (spec ? resolved) {
      inherit (patchedResolved) resolved integrity;
    } // lib.optionalAttrs (spec ? dependencies) {
      dependencies = (patchDependencies spec.dependencies);
    }
    );

  genericPackageName = name:
    (lib.last (lib.strings.splitString "node_modules/" name));

  # translate nix cpu name to node cpu names
  # nix cpu names:
  # nix-repl> lib.strings.concatStringsSep " " (lib.lists.naturalSort (lib.lists.unique (builtins.map (s: builtins.head (builtins.split "-" s)) lib.platforms.all)))
  # "aarch64 aarch64_be arm armv5tel armv6l armv7a armv7l avr i686 javascript loongarch64 m68k microblaze microblazeel mips mips64 mips64el mipsel mmix msp430 or1k powerpc powerpc64 powerpc64le powerpcle riscv32 riscv64 rx s390 s390x vc4 wasm32 wasm64 x86_64"
  # node cpu names: arm arm64 ia32 loong64 mips64el ppc64 riscv64 s390x x64 [TODO more]
  nodeHostCpuNames = ({
    "aarch64" = [ "aarch64" ];
    "aarch64_be" = [ "aarch64_be" ];
    "arm" = [ "arm" ];
    #"arm64" = [ "arm64" ]; # TODO
    "armv5tel" = [ "armv5tel" ];
    "armv6l" = [ "armv6l" ];
    "armv7a" = [ "armv7a" ];
    "armv7l" = [ "armv7l" ];
    "avr" = [ "avr" ];
    "i686" = [ "i686" "ia32" ]; # TODO verify "ia32"
    "javascript" = [ "javascript" ];
    "loongarch64" = [ "loongarch64" "loong64" ]; # TODO verify "loong64"
    "m68k" = [ "m68k" ];
    "microblaze" = [ "microblaze" ];
    "microblazeel" = [ "microblazeel" ];
    "mips" = [ "mips" ];
    "mips64" = [ "mips64" ];
    "mips64el" = [ "mips64el" ];
    "mipsel" = [ "mipsel" ];
    "mmix" = [ "mmix" ];
    "msp430" = [ "msp430" ];
    "or1k" = [ "or1k" ];
    "powerpc" = [ "powerpc" "ppc" ];
    "powerpc64" = [ "powerpc64" "ppc64" ];
    "powerpc64le" = [ "powerpc64le" "ppc64le" ];
    "powerpcle" = [ "powerpcle" "ppcle" ];
    "riscv32" = [ "riscv32" ];
    "riscv64" = [ "riscv64" ];
    "rx" = [ "rx" ];
    "s390" = [ "s390" ];
    "s390x" = [ "s390x" ];
    "vc4" = [ "vc4" ];
    "wasm32" = [ "wasm32" ];
    "wasm64" = [ "wasm64" ];
    "x86_64" = [ "x86_64" "x64" ];
  }).${stdenv.hostPlatform.parsed.cpu.name};

  # translate nix os name to node os names
  # nix os names:
  # nix-repl> lib.strings.concatStringsSep " " (lib.lists.naturalSort (lib.lists.unique (builtins.map (s: lib.lists.last (builtins.split "-" s)) lib.platforms.all)))
  # "cygwin darwin freebsd13 genode ghcjs linux mmixware netbsd none openbsd redox solaris wasi windows"
  # node os names: android darwin freebsd linux netbsd openbsd sunos win32 [TODO more]
  nodeHostOsNames = ({
    "android" = [ "android" ];
    "cygwin" = [ "cygwin" ];
    "darwin" = [ "darwin" ];
    "freebsd13" = [ "freebsd" ];
    "linux" = [ "linux" ];
    "netbsd" = [ "netbsd" ];
    "openbsd" = [ "openbsd" ];
    "redox" = [ "redox" ];
    "solaris" = [ "solaris" "sunos" ];
    "windows" = [ "win32" ];
  }).${stdenv.hostPlatform.parsed.kernel.name};

  # Description: Takes a parsed lockfile and returns the patched version as an attribute set
  # Type: { sourceHashFunc :: Fn } -> parsedLockedFile :: Set -> { result :: Set, integrityUpdates :: List { path, file } }
  patchLockfile = sourceOptions: content:
    if (content.lockfileVersion == 3 || content ? packages) then patchLockfileV2 sourceOptions content else # TODO verify
    if (content.lockfileVersion == 2 || content ? packages) then patchLockfileV2 sourceOptions content else
    if (content.lockfileVersion == 1 || content ? dependencies) then patchLockfileV1 sourceOptions content else
    if (content ? lockfileVersion) then throw "unknown lockfile version: ${content.lockfileVersion}" else
    throw "unknown lockfile content: ${builtins.substring 0 2048 (builtins.toJSON content)} [...]";

  patchLockfileV2 = sourceOptions: content:
    let
      contentWithoutDependencies = builtins.removeAttrs content [ "dependencies" ];
      packagesWithoutSelf = lib.filterAttrs (n: v: n != "") content.packages;
      topLevelPackage = content.packages."";
      patchedPackages = lib.mapAttrs (name: patchPackage sourceOptions name) packagesWithoutSelf;
    in
    {
      result = contentWithoutDependencies // {
        packages = patchedPackages // { "" = topLevelPackage; };
      };
    };

  # Description: Takes a Path to a lockfile and returns the patched version as attribute set
  # Type: { sourceHashFunc :: Fn } -> Path -> { result :: Set, integrityUpdates :: List { path, file } }
  patchLockfileV1 = sourceOptions: content:
    let
      dependencies = lib.mapAttrs (name: patchDependencyV1 [ name ] sourceOptions name) content.dependencies;
    in
    {
      result = content // {
        dependencies = lib.mapAttrs (_: value: value.result) dependencies;
      };
      integrityUpdates = lib.concatMap (value: value.integrityUpdates) (lib.attrValues dependencies);
    };

  # Description: Patches a single lockfile dependency (recursively) by replacing the resolved URL with a store path
  # Type: List String -> { sourceHashFunc :: Fn } -> String -> Set -> { result :: Set, integrityUpdates :: List { path, file } }
  patchDependencyV1 = path: sourceOptions: name: spec:
    assert (builtins.typeOf name != "string") ->
      throw "Name of dependency ${toString name} must be a string";
    assert (builtins.typeOf spec != "set") ->
      throw "spec of dependency ${toString name} must be a set";
    let
      isBundled = spec ? bundled && spec.bundled == true;
      hasGitHubRequires = spec: (spec ? requires) && (lib.any (x: lib.hasPrefix "github:" x) (lib.attrValues spec.requires));
      patchSource = lib.optionalAttrs (!isBundled) (makeSourceV1 sourceOptions name spec);
      patchRequiresSources = lib.optionalAttrs (hasGitHubRequires spec) { requires = (patchRequiresV1 sourceOptions name spec.requires); };
      nestedDependencies = lib.mapAttrs (name: patchDependencyV1 (path ++ [ name ]) sourceOptions name) spec.dependencies;
      patchDependenciesSources = lib.optionalAttrs (spec ? dependencies) { dependencies = lib.mapAttrs (_: value: value.result) nestedDependencies; };
      nestedIntegrityUpdates = lib.concatMap (value: value.integrityUpdates) (lib.attrValues nestedDependencies);

      # For our purposes we need a dependency with
      # - `resolved` set to a path in the nix store (`patchSource`)
      # - All `requires` entries of this dependency that are set to github URLs set to a path in the nix store (`patchRequiresSources`)
      # - This needs to be done recursively for all `dependencies` in the lockfile (`patchDependenciesSources`)
      result = spec // patchSource // patchRequiresSources // patchDependenciesSources;
    in
    {
      result = result;
      integrityUpdates = lib.optional (result ? resolved && result ? integrity && result.integrity == null) {
        inherit path;
        file = lib.removePrefix "file://" result.resolved;
      };
    };

  # Description: Patch the `requires` attributes of a dependency spec to refer to paths in the store
  # Type: { sourceHashFunc :: Fn } -> String -> Set -> Set
  patchRequiresV1 = sourceOptions: name: requires:
    let
      patchReq = name: version: if lib.hasPrefix "github:" version then stringToTgzPathV1 sourceOptions name version else version;
    in
    lib.mapAttrs patchReq requires;

  # Description: Turns an npm lockfile dependency into a fetchurl derivation
  # Type: { sourceHashFunc :: Fn } -> String -> Set -> Derivation
  makeSourceV1 = sourceOptions: name: dependency:
    assert (builtins.typeOf name != "string") ->
      throw "Name of dependency ${toString name} must be a string";
    assert (builtins.typeOf dependency != "set") ->
      throw "Specification of dependency ${toString name} must be a set";
    if dependency ? resolved && dependency ? integrity then
      makeUrlSourceV1 sourceOptions name dependency
    else if dependency ? from && dependency ? version then
      makeGithubSourceV1 sourceOptions name dependency
    else if shouldUseVersionAsUrlV1 dependency then
      makeSourceV1 sourceOptions name (dependency // { resolved = dependency.version; })
    else throw (
      "A valid dependency consists of at least the resolved and integrity field. " +
      "Missing one or both of them for `${name}`. " +
      "The object I got looks like this: ${builtins.toJSON dependency}"
    );

  # Description: Replaces the `resolved` field of a dependency with a
  # prefetched version from the Nix store. Patches specified with sourceOverrides
  # will be applied, in which case the `integrity` attribute is set to `null`,
  # in order to be recomputer later
  # Type: { sourceOverrides :: Fn, nodejs :: Package } -> String -> Set -> Set
  makeUrlSourceV1 = sourceOptions: name: dependency:
    let
      sourceOverrides = sourceOptions.sourceOverrides;
      src-packed = fetchurl (makeSourceAttrsV1 name dependency);
      src =
        if sourceOptions.symlinkNodeModules
        #then (builtins.trace "npmlock2nix: unpacking source: ${src-packed}") unpackNpmTgz src-packed
        then unpackNpmTgz src-packed
        else src-packed;
      sourceInfo = {
        inherit (dependency) version;
      };
      drv = packTgz sourceOptions name dependency.version src;
      tgz =
        if sourceOverrides ? ${name}
        # If we have modification to this source, unpack the tgz, apply the
        # patches and repack the tgz
        then sourceOverrides.${name} sourceInfo drv
        else src;
      resolved = (if sourceOptions.symlinkNodeModules then "" else "file://") + toString tgz;
    in
    dependency // { inherit resolved; } // lib.optionalAttrs (sourceOverrides ? ${name}) {
      # Integrity was tampered with due to the source attributes, so it needs
      # to be recalculated, which is done in the node_modules builder
      integrity = null;
    };

  # Description: Turns a dependency with a from field of the format
  # `github:org/repo#revision` into a git fetcher. The fetcher can
  # receive a hash value by calling 'sourceHashFunc' if a source hash
  # map has been provided. Otherwise the function yields `null`. Patches
  # specified with sourceOverrides will be applied
  # Type: { sourceHashFunc :: Fn } -> String -> Set -> Path
  makeGithubSourceV1 = sourceOptions: name: dependency:
    assert !(dependency ? version) ->
      builtins.throw "version` attribute missing from `${name}`";
    assert (lib.hasPrefix "github: " dependency.version) -> builtins.throw "invalid prefix for `version` field of `${name}` expected `github:`, got: `${dependency.version}`.";
    let
      v = parseGitHubRef dependency.version;
      f = parseGitHubRef dependency.from;
    in
    assert v.org != f.org -> throw "version and from of `${name}` disagree on the GitHub org to fetch from: `${v.org}` vs `${f.org}`";
    assert v.repo != f.repo -> throw "version and from of `${name}` disagree on the GitHub repo to fetch from: `${v.repo}` vs `${f.repo}`";
    assert !isGitRevV1 v.rev -> throw "version of `${name}` does not specify a valid git rev: `${v.rev}`";
    let
      src = buildTgzFromGitHub {
        name = "${name}.tgz";
        ref = f.rev;
        inherit (v) org repo rev;
        hash = sourceOptions.sourceHashFunc { type = "github"; value = v; };
        inherit sourceOptions;
      };
    in
    (builtins.removeAttrs dependency [ "from" ]) // {
      version = "file://" + (toString src);
    };

  # Description: Checks the given dependency spec if its version field should
  # be used as URL in absence of a resolved attribute. In some cases the
  # resolved field is missing but the version field contains a valid URL.
  # Type: Set -> Bool
  shouldUseVersionAsUrlV1 = dependency:
    dependency ? version && dependency ? integrity && ! (dependency ? resolved) && looksLikeUrlV1 dependency.version;

  # Description: Turns a github string reference into a store path with a tgz of the reference
  # Type: Fn -> String -> String -> Path
  stringToTgzPathV1 = sourceOptions: name: str:
    let
      gitAttrs = parseGitHubRef str;
    in
    buildTgzFromGitHub {
      name = "${name}.tgz";
      ref = gitAttrs.rev;
      inherit (gitAttrs) org repo rev;
      hash = sourceOptions.sourceHashFunc { type = "github"; value = gitAttrs; };
      inherit sourceOptions;
    };

  # Description: Turns an npm lockfile dependency into an attribute set as needed by fetchurl
  # Type: String -> Set -> Set
  makeSourceAttrsV1 = name: dependency:
    assert !(dependency ? resolved) -> throw "Missing `resolved` attribute for dependency `${name}`.";
    assert !(dependency ? integrity) -> throw "Missing `integrity` attribute for dependency `${name}`.";
    {
      url = dependency.resolved;
      # FIXME: for backwards compatibility we should probably set the
      #        `sha1`, `sha256`, `sha512` … attributes depending on the string
      #        content.
      hash = dependency.integrity;
    };

  # Description: Checks if a string looks like a valid git revision
  # Type: String -> Boolean
  isGitRevV1 = str:
    (builtins.match "[0-9a-f]{40}" str) != null;

  # Description: Checks if the given string looks like a vila HTTP or HTTPS url
  # Type: String -> Bool
  looksLikeUrlV1 = s:
    assert (builtins.typeOf s != "string") -> throw "can only check strings if they are URL-like";
    lib.hasPrefix "http://" s || lib.hasPrefix "https://" s;

  # Description: Rewrite all the `github:` references to wildcards.
  # Type: Path -> Set
  patchPackagefile = sourceOptions: patchedLockfileData: content:
    let
      patchDep = (name: version:
        # If the dependency is of the form github:owner/repo#branch or
        # http(s)://..., the package-lock.json contains the specific
        # revision that the branch was pointing at at the time of npm install.
        # The package.json itself does not contain enough information to resolve a specific dependency,
        # because it only contains the branch name. Therefore we cannot substitute with a nix store path.
        # If we leave the dependency unchanged, npm will try to resolve it and fail. We therefore substitute with a
        # wildcard dependency, which will make npm look at the lockfile.
        if ((isGitHubRef version) || (lib.hasPrefix "http" version)) then
          "*"
        # error: attribute 'some-package' missing
        #else if version == "latest" then sourceOptions.packagesVersions.${name}.version
        else if (version == "latest" && sourceOptions.packagesVersions ? ${name}) then (
          #(builtins.trace "npmlock2nix: ${name}:latest -> ${name}:${sourceOptions.packagesVersions.${name}.version}")
          sourceOptions.packagesVersions.${name}.version
        )
        # lockfileVersion 2
        else if (version == "latest" && sourceOptions.packagesVersions ? "node_modules/${name}") then (
          #(builtins.trace "npmlock2nix: ${name}:latest -> ${name}:${sourceOptions.packagesVersions."node_modules/${name}".version}")
          sourceOptions.packagesVersions."node_modules/${name}".version
        )
        else (
          (builtins.trace "npmlock2nix: ${name}:latest -> ${name}:latest (FIXME find locked version in sourceOptions.packagesVersions names ${builtins.toJSON (builtins.attrNames sourceOptions.packagesVersions)})")
          version
        ));
      dependencies = if (content ? dependencies) then lib.mapAttrs patchDep content.dependencies else { };
      devDependencies = if (content ? devDependencies) then lib.mapAttrs patchDep content.devDependencies else { };
    in
    content // { inherit devDependencies dependencies; };

  # Description: Takes a parsed package file and returns the patched version as file in the Nix store
  # Type: { sourceHashFunc :: Fn } -> parsedPackageFile :: Set -> Derivation
  # TODO add name + version to filename
  patchedPackagefile = pname: version: patchedPackagefileData:
    writeText "${pname}-${version}-package.json" (builtins.toJSON patchedPackagefileData);

  # Description: Takes a Path to a lockfile and returns the patched version as file in the Nix store
  # Type: { sourceHashFunc :: Fn } -> parsedLockFile :: Set -> Path
  # TODO add name + version to filename
  patchedLockfile = pname: version: patchedLockfileData:
    writeText "${pname}-${version}-package-lock.json" (builtins.toJSON patchedLockfileData.result);

  # Description: Turn a derivation (with name & src attribute) into a directory containing the unpacked sources
  # Type: Derivation -> Derivation
  nodeSource = nodejs: runCommand "node-sources-${nodejs.version}"
    { } ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';

  # Description: Creates shell scripts to provide node_modules to the environment supporting
  # two different modes: "symlink" and "copy"
  # Type: Derivation -> String -> String
  add_node_modules_to_cwd = node_modules: mode:
    ''
      # If node_modules is a managed symlink we can safely remove it and install a new one
      ${lib.optionalString (mode == "symlink") ''
        if [[ "$(readlink -f node_modules)" == ${builtins.storeDir}* ]]; then
          rm -f node_modules
        fi
      ''}

      if test -e node_modules; then
        echo '[npmlock2nix] There is already a `node_modules` directory. Not replacing it.' >&2
        exit 1
      fi
    '' +
    (
      if mode == "copy" then ''
        cp --no-preserve=mode -r ${node_modules}/node_modules node_modules
        chmod -R u+rw node_modules
      '' else if mode == "symlink" then ''
        ln -s ${node_modules}/node_modules node_modules
      '' else throw "node_modules_mode must be either `copy` or `symlink`"
    ) + ''
      export NODE_PATH="$(pwd)/node_modules:$NODE_PATH"
    '';

  # Description: Extract the attributes that are relevant for building node_modules and use
  # them as defaults in case the node_modules_attrs attribute doesn't have
  # them.
  # Type: Set -> Set
  get_node_modules_attrs = { node_modules_attrs ? { }, ... }@attrs:
    let
      getAttr = name: from: lib.optionalAttrs (builtins.hasAttr name from) { "${name}" = from.${name}; };
      getAttrs = names: from: lib.foldl (a: b: a // (getAttr b from)) { } names;
    in
    (getAttrs [ "src" "nodejs" ] attrs // node_modules_attrs);

  # Description: Takes a dependency spec and a map of github sources/hashes and returns either the map or 'null'
  # Type: Set -> Set -> Set | null
  sourceHashFunc = githubSourceHashMap: spec:
    if spec.type == "github" then
      lib.attrByPath
        [ spec.value.org spec.value.repo spec.value.rev ]
        (
          lib.traceSeq
            "[npmlock2nix] warning: missing attr in githubSourceHashMap: ${spec.value.org}.${spec.value.repo}.${spec.value.rev}"
            null
        )
        githubSourceHashMap
    else
      throw "sourceHashFunc: spec.type '${spec.type}' is not supported. Supported types: 'github'";

  node_modules =
    { src ? /var/empty
    , packageJson ? src + "/package.json"
    , packageLockJson ? src + "/package-lock.json"
    , buildInputs ? [ ]
    , nativeBuildInputs ? [ ]
    , nodejs ? default_nodejs
    , preBuild ? ""
    , postBuild ? ""
    , preInstallLinks ? null
    , sourceOverrides ? { }
    , githubSourceHashMap ? { }
    , symlinkNodeModules ? false
    , passthru ? { }
    , ...
    }@args:
      #lib.traceSeqN 1 { inherit symlinkNodeModules pnpm-install-only; }
      (
      assert (preInstallLinks != null) ->
        throw "`preInstallLinks` was removed use `sourceOverrides";
      # TODO shorter?
      assert !(
        (symlinkNodeModules == true && pnpm-install-only != null) ||
        (symlinkNodeModules == false)
      ) ->
        throw "(symlinkNodeModules == true) requires (pnpm-install-only != null)";
      # TODO shorter?
      assert !(
        (symlinkNodeModules == true && nodejs-hide-symlinks != null) ||
        (symlinkNodeModules == false)
      ) ->
        throw "(symlinkNodeModules == true) requires (nodejs-hide-symlinks != null)";
      let
        cleanArgs = builtins.removeAttrs args [ "src" "packageJson" "packageLockJson" "buildInputs" "nativeBuildInputs" "nodejs" "preBuild" "postBuild" "sourceOverrides" "githubSourceHashMap" ];
        lockfile = readPackageLikeFile packageLockJson;
        packagefile = readPackageLikeFile packageJson;

        sourceOptions = {
          sourceHashFunc = sourceHashFunc githubSourceHashMap;
          inherit sourceOverrides symlinkNodeModules nodeHostCpuNames nodeHostOsNames;
          nodejs = if symlinkNodeModules then (nodejs-hide-symlinks.override { inherit nodejs; }) else nodejs;
          packagesVersions = lockfile.packages or { };
        };

        allDependenciesNames = builtins.attrNames (packagefile.dependencies // packagefile.devDependencies or { });

        patchedLockfileData = patchLockfile sourceOptions lockfile;
        patchedPackagefileData = patchPackagefile sourceOptions patchedLockfileData packagefile;

        # TODO allow to override pname and version
        pname = patchedLockfileData.result.name or "package";
        version = patchedLockfileData.result.version or "0.0.0";

        patchedLockfilePath = patchedLockfile pname version patchedLockfileData;
        patchedPackagefilePath = patchedPackagefile pname version patchedPackagefileData;
      in
      stdenv.mkDerivation ({
        pname = lib.strings.sanitizeDerivationName lockfile.name;
        version = (lockfile.version or "0") + "-node-modules";
        dontUnpack = true;

        inherit nativeBuildInputs buildInputs preBuild postBuild;
        propagatedBuildInputs = [
          sourceOptions.nodejs
        ];

        setupHooks = [
          ./set-node-path.sh
        ];

        preConfigure = ''
          export HOME=$TMP
        '';

        postPatch = ''
          ln -sf ${patchedLockfilePath} package-lock.json
          ln -sf ${patchedPackagefilePath} package.json
        '';

        buildPhase = ''
          runHook preBuild
          export HOME=$TMP

          ${if sourceOptions.symlinkNodeModules then ''

          echo "symlinkNodeModules=true -> using pnpm-install-only to populate node_modules/"

          # FIXME store preInstallLinks in a file, pass as argument to index.js
          export NODE_preInstallLinks='${builtins.toJSON preInstallLinks}'

          echo '$' node --trace-uncaught --trace-warnings ${pnpm-install-only}/bin/pnpm-install-only

          if ! node --trace-uncaught --trace-warnings ${pnpm-install-only}/bin/pnpm-install-only; then
            echo "ERROR failed to install NPM packages with ${pnpm-install-only}/bin/pnpm-install-only"
            exit 1
          fi

          '' else ''

          echo "symlinkNodeModules=false -> using npm to populate node_modules/"

          function patchShebangsInNodeModulesBin() {
            if ! [ -d "$1" ]; then return; fi
            echo "patching shebangs in $1"
            find "$1" -mindepth 1 -maxdepth 1 -not -type d | while read binpath; do
              binpath="$(readlink -f "$binpath")"
              # FIXME make this work in a read-only node_modules/ -> use wrapper scripts like pnpm
              chmod +x "$binpath"
              patchShebangs "$binpath"
            done
            patchShebangs "$1"
          }

          npm ci --nodedir=${nodeSource sourceOptions.nodejs} --ignore-scripts --offline
          patchShebangsInNodeModulesBin node_modules/.bin

          ''}

          runHook postBuild
        '';
        installPhase = ''
          mkdir "$out"
          if test -d node_modules; then
            if [ $(ls -1 node_modules | wc -l) -gt 0 ] || [ -e node_modules/.bin ]; then
              mv node_modules $out/
              if test -d $out/node_modules/.bin; then
                ln -s $out/node_modules/.bin $out/bin
              fi
            fi
          fi
        '';

        passthru = passthru // {
          inherit (sourceOptions) nodejs;
          lockfile = patchedLockfilePath;
          packagesfile = patchedPackagefilePath;
        };
      } // cleanArgs)
      );

  shell =
    { src
    , node_modules_mode ? "symlink"
    , node_modules_attrs ? { }
    , buildInputs ? [ ]
    , passthru ? { }
    , shellHook ? ""
    , ...
    }@attrs:
    let
      nm = node_modules (get_node_modules_attrs attrs);
      extraAttrs = builtins.removeAttrs attrs [ "node_modules_attrs" "passthru" "shellHook" "buildInputs" ];
    in
    mkShell ({
      buildInputs = buildInputs ++ [ nm.nodejs nm ];
      shellHook = ''
        # FIXME: we should somehow register a GC root here in case of a symlink?
        ${add_node_modules_to_cwd nm node_modules_mode}
      '' + shellHook;
      passthru = passthru // {
        node_modules = nm;
      };
    } // extraAttrs);

  build =
    { src
    , buildCommands ? [ "npm run build" ]
    , installPhase
    , node_modules_attrs ? { }
    , node_modules_mode ? "symlink"
    , buildInputs ? [ ]
    , passthru ? { }
    , ...
    }@attrs:
    let
      nm = node_modules (get_node_modules_attrs attrs);
      extraAttrs = builtins.removeAttrs attrs [ "node_modules_attrs" "passthru" "buildInputs" ];
    in
    stdenv.mkDerivation ({
      pname = nm.pname;
      version = nm.version;
      buildInputs = [ nm ] ++ buildInputs;
      inherit src installPhase;

      preConfigure = add_node_modules_to_cwd nm node_modules_mode;

      buildPhase = ''
        export HOME=$TMP
        runHook preBuild
        ${lib.concatStringsSep "\n" buildCommands}
        runHook postBuild
      '';

      passthru = passthru // { node_modules = nm; };
    } // extraAttrs);
}
