{ nodejs-16_x, jq, openssl, coreutils, stdenv, mkShell, lib, fetchurl, writeText, writeShellScript, runCommand, fetchFromGitHub }:
rec {
  default_nodejs = nodejs-16_x;

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
    let
      parts = builtins.split "[:#/@]" str;
      partsLen = builtins.length parts;
    in
    if partsLen == 7 || partsLen == 9 || partsLen == 15
    then
      (
        ((builtins.elemAt parts 0) == "github") ||
        ((builtins.elemAt parts 2) == "github.com") ||
        ((builtins.elemAt parts 2) == "github") ||
        ((builtins.elemAt parts 8) == "github.com")
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
      drv = packTgz sourceOptions.nodejs name ref src;
    in
    if sourceOptions ? sourceOverrides.${name}
    then sourceOptions.sourceOverrides.${name} sourceInfo drv
    else drv;

  # Description: Packs a source directory into a .tgz tar archive. If the
  # source is an archive, it gets unpacked first.
  # Type: Path -> String -> String -> Path -> Path
  packTgz = nodejs: pname: version: src: stdenv.mkDerivation (
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
      name = lib.strings.sanitizeDerivationName "${pname}-${version}.tgz";
      id = "id_" + (builtins.replaceStrings [ "-" "." ] [ "_" "_" ] name);

      phases = "unpackPhase patchPhase installPhase";

      inherit src;
      sourceRoot = "package";
      outputs = [ "out" "hash" ];
      nativeBuildInputs = [ jq openssl ];

      propagatedBuildInputs = [
        nodejs
      ];

      unpackPhase = ''
        runHook preUnpack
        mkdir -p ${sourceRoot}
        [[ -d ${src} ]] && cp -RT --reflink=auto ${src} ${sourceRoot}
        [[ -f ${src} ]] && tar --no-same-owner --strip-components=1 --warning=no-timestamp -xf ${src} -C ${sourceRoot}
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
        tar -C . -czf $out ./
        echo sha512-$(openssl dgst -sha512 -binary $out | openssl base64 -A) > $hash
        runHook postInstall
      '';
    }
  );

  # Description: Replaces the `resolved` field of a dependency with a
  # prefetched version from the Nix store. Patches specified with sourceOverrides
  # will be applied, in which case the `integrity` attribute is set to `null`,
  # in order to be recomputer later
  # Type: { sourceOverrides :: Fn, nodejs :: Package } -> String -> String -> String -> String -> { resolved :: Path, integrity :: String }
  makeUrlSource = { sourceOverrides ? { }, nodejs, ... }: name: version: resolved: integrity:
    let
      src = fetchurl {
        # Npm strips the query strings when opening a "file://.*" name.
        # We need to make sure we strip the query string before adding
        # the file to the store.
        name = builtins.elemAt (lib.splitString "?" (builtins.baseNameOf resolved)) 0;
        url = resolved;
        hash = integrity;
      };
      sourceInfo = {
        version = version;
      };
      drv = packTgz nodejs name version src;
      tgz = (
        if sourceOverrides ? ${name} then
        # If we have modification to this source, unpack the tgz, apply the
        # patches and repack the tgz
          sourceOverrides.${name} sourceInfo drv
        else
          if sourceOverrides.buildRequirePatchShebangs or false then drv else src
      );
    in
    {
      inherit integrity;
      resolved = "file://" + (toString tgz);
    } // lib.optionalAttrs (tgz != src) {
      # Integrity was tampered with due to the source attributes, so it needs
      # to be recalculated, which is done in the node_modules builder
      integrity = null;
    };


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

  # Description: Patch a lockfile v2 package entry. It'll replace the
  # URL stored in the integrity field with nix store path.
  # spec :: {version :: String, resolved :: String, integrity :: String }.
  # Type: { version :: String, resolved :: String, integrity :: String }
  patchPackage = sourceOptions@{ sourceHashFunc, ... }: raw_name: spec:
    assert (builtins.typeOf raw_name != "string") ->
      throw "Name of dependency ${toString raw_name} must be a string";
    assert !(spec ? resolved || (spec ? inBundle && spec.inBundle == true)) ->
      throw "Missing resolved field for dependency ${toString raw_name}";
    assert !(spec ? version) ->
      throw "Missing version field for dependency ${toString raw_name}";
    let
      name = genericPackageName raw_name;
      defaultedIntegrity = if spec ? integrity then spec.integrity else null;
      # Relaxing dependencies version bounds: it could be a GitHub
      # ref, forcing NPM to checkout the remote repo to get the actual
      # version.
      # We already pinned everything through the "resolved", we can
      # relax those.
      patchDependencies = deps: lib.mapAttrs (_n: dep: if isGitHubRef dep || isGitHubRefWithoutRev dep then "*" else dep) deps;
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
              hash = sourceHashFunc { type = "github"; value = { inherit (ghRef) org repo rev; }; };
            };
          in
          {
            resolved = "file://" + (toString ghTgz);
            integrity = null;
          };
    in
    (builtins.removeAttrs spec [ "peerDependencies" ]) //
    lib.optionalAttrs (spec ? resolved) {
      inherit (patchedResolved) resolved integrity;
    } // lib.optionalAttrs (spec ? dependencies) {
      dependencies = (patchDependencies spec.dependencies);
    };

  genericPackageName = name:
    (lib.last (lib.strings.splitString "node_modules/" name));

  # Description: Takes a parsed lockfile and returns the patched version as an attribute set
  # Type: { sourceHashFunc :: Fn } -> parsedLockedFile :: Set -> { result :: Set, integrityUpdates :: List { path, file } }
  patchLockfile = sourceOptions: content:
    let
      contentWithoutDependencies = builtins.removeAttrs content [ "dependencies" ];
      packagesWithoutSelf = lib.filterAttrs (n: v: n != "") content.packages;
      topLevelPackage = lib.filterAttrs (n: v: n == "") content.packages;
      patchedPackages = lib.mapAttrs (name: patchPackage sourceOptions name) packagesWithoutSelf;
    in
    assert !(content ? packages) ->
      throw "Missing the packages top-level key in your lockfile. Are you sure it is a npm lockfile v2?";
    {
      result = contentWithoutDependencies // {
        packages = patchedPackages // topLevelPackage;
      };
    };

  # Description: Rewrite all the `github:` references to wildcards.
  # Type: Path -> Set
  patchPackagefile = sourceOptions: content:
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
        else if version == "latest" then sourceOptions.packagesVersions.${name}.version else version);
      dependencies = if (content ? dependencies) then lib.mapAttrs patchDep content.dependencies else { };
      devDependencies = if (content ? devDependencies) then lib.mapAttrs patchDep content.devDependencies else { };
    in
    content // { inherit devDependencies dependencies; };

  # Description: Takes a parsed package file and returns the patched version as file in the Nix store
  # Type: { sourceHashFunc :: Fn } -> parsedPackageFile :: Set -> Derivation
  patchedPackagefile = sourceOptions: parsedPackageFile: writeText "package.json"
    (
      builtins.toJSON (patchPackagefile sourceOptions parsedPackageFile)
    );

  # Description: Takes a Path to a lockfile and returns the patched version as file in the Nix store
  # Type: { sourceHashFunc :: Fn } -> parsedLockFile :: Set -> Path
  patchedLockfile = sourceOptions: parsedLockFile:
    let
      patched = patchLockfile sourceOptions parsedLockFile;
    in
    writeText "package-lock.json" (builtins.toJSON patched.result);

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
    { src
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
    , passthru ? { }
    , ...
    }@args:
      assert (preInstallLinks != null) ->
        throw "`preInstallLinks` was removed use `sourceOverrides";
      let
        cleanArgs = builtins.removeAttrs args [ "src" "packageJson" "packageLockJson" "buildInputs" "nativeBuildInputs" "nodejs" "preBuild" "postBuild" "sourceOverrides" "githubSourceHashMap" ];
        lockfile = readPackageLikeFile packageLockJson;
        packagefile = readPackageLikeFile packageJson;

        sourceOptions = {
          sourceHashFunc = sourceHashFunc githubSourceHashMap;
          inherit nodejs sourceOverrides;
          packagesVersions = lockfile.packages or { };
        };

        allDependenciesNames = builtins.attrNames (packagefile.dependencies // packagefile.devDependencies or { });

        patchedLockfilePath = patchedLockfile sourceOptions lockfile;
        patchedPackagefilePath = patchedPackagefile sourceOptions packagefile;
      in
      assert lockfile.lockfileVersion == 2 && lib.versionOlder nodejs.version "15.0"
        -> throw "npm lockfile V2 require nodejs version >= 15, it is not supported by nodejs ${nodejs.version}";
      stdenv.mkDerivation ({
        pname = lib.strings.sanitizeDerivationName lockfile.name;
        version = lockfile.version or "0";
        dontUnpack = true;

        inherit nativeBuildInputs buildInputs preBuild postBuild;
        propagatedBuildInputs = [
          nodejs
        ];

        setupHooks = [
          ./set-node-path.sh
        ];

        preConfigure = ''
          export HOME=$(mktemp -d)
        '';

        postPatch = ''
          ln -sf ${patchedLockfilePath} package-lock.json
          ln -sf ${patchedPackagefilePath} package.json
        '';

        buildPhase = ''
          runHook preBuild
          export HOME=.
          npm ci --nodedir=${nodeSource nodejs} --ignore-scripts
          test -d node_modules/.bin && patchShebangs node_modules/.bin
          npm rebuild --offline --nodedir=${nodeSource nodejs} ${builtins.concatStringsSep " " allDependenciesNames}
          npm install --no-save --offline --nodedir=${nodeSource nodejs}
          test -d node_modules/.bin && patchShebangs node_modules/.bin
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
          inherit nodejs;
          lockfile = patchedLockfilePath;
          packagesfile = patchedPackagefilePath;
        };
      } // cleanArgs);

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
        runHook preBuild
        ${lib.concatStringsSep "\n" buildCommands}
        runHook postBuild
      '';

      passthru = passthru // { node_modules = nm; };
    } // extraAttrs);
}
