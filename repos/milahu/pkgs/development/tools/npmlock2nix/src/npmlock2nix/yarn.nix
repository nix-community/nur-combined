# Helper library to parse yarn.lock files that are some custom format and not just JSON :(
{ lib
, internal
, stdenv
, nodejs
, yarn
, writeText
, pnpm-install-only ? null
, nodejs-hide-symlinks ? null
}:

let
  default_nodejs = nodejs;

  # Description: Split a file into logicla blocks of "dependencies", on dependency per block.
  # Type: String -> [ String ]
  splitBlocks = text:
    assert builtins.typeOf text != "string" -> throw "Expected the argument text to be of type string. Got ${builtins.toJSON text}";
    let blocks = builtins.split "\n\n" text;
    in builtins.filter (x: (
      builtins.typeOf x == "string" &&
      # fix: error: no resolved line found in block for package __metadata
      # ignore the metadata block
      #   __metadata:
      #     version: 8
      #     cacheKey: 10
      builtins.substring 0 11 x != "__metadata:"
    )) blocks;


  # Description: Unquote a given string, e.g remove the quotes around a value
  # Type: String -> String
  # Note: It does not check if the quotes are well-formed (aka. that there is one at the start and one at the beginning).
  unquote = text:
    if text == null then text else
    #builtins.trace "npmlock2nix/yarn.nix unquote ${builtins.toJSON { inherit text; }}"
    assert builtins.typeOf text != "string" -> throw "Expected the argument text to be of type string. Got ${builtins.toJSON text}";
    let
      s = if lib.hasPrefix "\"" text then builtins.substring 1 (builtins.stringLength text) text else text;
    in
    if (s != "") then
      if lib.hasSuffix "\"" s then builtins.substring 0 ((builtins.stringLength s) - 1) s else s else s;


  # Description: Parse a single "block" from the lock file into an attrset
  # Type: String -> Attrset

  parseBlock = block:
    let
      getField = fieldName: prefixes: body:
      #builtins.trace "body: ${builtins.toJSON { inherit name fieldName prefixes body; }}"
      (
        let
          cutPrefix = prefix: x: builtins.substring (builtins.stringLength prefix) (builtins.stringLength x) x;
          ls = lib.flatten (map (prefix: map (cutPrefix prefix) (builtins.filter (lib.hasPrefix prefix) body)) prefixes);
          line = (
            if builtins.length ls == 0 then null else
            if builtins.length ls == 1 then builtins.head ls else
            throw "getField: multiple ${fieldName} lines found in block for package ${name}"
          );
        in
        line
      );

      lines =
        let
          ls = builtins.filter (x: builtins.typeOf x != "list") (builtins.split "\n" block);
        in
        ls;
      name = let x = builtins.head lines; in
        assert !(lib.hasSuffix ":" x) -> throw "`name` line is malformed, must end with a colon. Got: \"${x}\"";
        unquote (lib.substring 0 ((builtins.stringLength x) - 1) x);

      body =
        let
          ls = builtins.tail lines;
          strippedLines = map (line: assert line != "" && !lib.hasPrefix "  " line -> throw "invalid line (`${line}`) in block for ${name}"; builtins.substring 2 (builtins.stringLength line) line) ls;
        in
        strippedLines;

      version =
        #lib.traceSeq { f = "parseBlock version"; inherit body; versionRaw = (getField "version" ["version " "version: "] body); }
        unquote (getField "version" ["version " "version: "] body);

      resolved =
        lib.traceSeq { f = "parseBlock resolved"; inherit body; resolvedRaw = (getField "resolved" ["resolved " "resolution: "] body); }
        #unquote (getField "resolved" ["resolved " "resolution: "] body);
        unquote (getField "resolved" ["resolved "] body);
        #getUrlOfResolution (unquote (getField "resolved" ["resolved " "resolution: "] body));

      resolution =
        #lib.traceSeq { f = "parseBlock resolved"; inherit body; resolvedRaw = (getField "resolved" ["resolved " "resolution: "] body); }
        unquote (getField "resolution" ["resolution: "] body);
        #getUrlOfResolution (unquote (getField "resolved" ["resolved " "resolution: "] body));

      resolvedOrResolution =
        if resolved != null then resolved else
        if resolution != null then resolution else
        throw "no dep.resolved and no dep.resolution";

      integrity =
        #lib.traceSeq { f = "parseBlock integrity"; inherit body; integrityRaw = (getField "integrity" ["integrity " "checksum: "] body); sriHash = (guessSriHash (getField "integrity" ["integrity " "checksum: "] body)); }
        getField "integrity" ["integrity " "checksum: "] body;
        #guessSriHash (getField "integrity" ["integrity " "checksum: "] body);

      dependencies = parseDependencies body;
    in
    ({
      inherit name version resolved resolution resolvedOrResolution;
    })// (
      let res = builtins.tryEval integrity; in if res.success then { integrity = res.value; } else { }
    )

    // (if dependencies != null then { inherit dependencies; } else { });

  parseDependencies = lines:
    let
      parseDepLine = acc: cur:
        let
          a = if acc != null then acc else { deps = { }; };
        in
        if lib.hasPrefix "  " cur then
          let
            stripped = builtins.substring 2 (builtins.stringLength cur) cur;
            parts = builtins.filter (x: x != [ ]) (builtins.split " " stripped);
            name = unquote (lib.head parts);
            version = unquote (lib.head (lib.tail parts));
          in
          { deps = a.deps // { ${name} = version; }; }
        else { inherit (a) deps; done = true; };
      innerFn = acc: cur: if acc != null || cur == "dependencies:" then parseDepLine acc cur else acc;
      res = builtins.foldl' innerFn null lines;
    in
    if res == null then null else res.deps;

  stripLeadingEmptyLines = lines:
    let
      head = builtins.head lines;
      tail = builtins.tail lines;
    in
    if head == "" then stripLeadingEmptyLines tail else lines;

  removePreamble = text:
    let
      lines = builtins.filter (x: x != [ ]) (builtins.split "\n" text);
      nonCommentLines = builtins.filter (line: !lib.hasPrefix "#" line) lines;
      nonEmptyLeadingLines = stripLeadingEmptyLines nonCommentLines;
    in
    lib.concatStringsSep "\n" nonEmptyLeadingLines;

  parseLockFileText = lockfileText:
    #map parseBlock (builtins.filter (block: block != "") (splitBlocks lockfileText));
    map parseBlock (builtins.filter (block: block != "") ([(builtins.head (splitBlocks lockfileText))])); # debug: only first
    #map parseBlock (builtins.filter (block: block != "") ([(builtins.elemAt (splitBlocks lockfileText) 1)])); # debug: only second

  # guess hash type
  guessSriHash = integrityPadded:
    let
      integrity = builtins.head (
        let parts = builtins.match "([^=]+)=*" integrityPadded; in
        assert (parts == null) ->
          throw "guessSriHash: failed to parse integrityPadded ${builtins.toJSON integrityPadded}";
        parts
      );
      len = lib.stringLength integrity;
      isBase16 = builtins.match "[0-9a-fA-F]+" integrity != null;
      isBase64 = builtins.match "[0-9a-zA-Z/+]+" integrity != null;
      prefix = (
        # base16 -> ":" separator
        if len == 40 && isBase16 then "sha1:" else
        if len == 56 && isBase16 then "sha224:" else
        if len == 64 && isBase16 then "sha256:" else
        if len == 96 && isBase16 then "sha384:" else
        if len == 128 && isBase16 then "sha512:" else
        # base64 -> "-" separator
        if len == 27 && isBase64 then "sha1-" else
        if len == 40 && isBase16 then "sha224-" else
        if len == 43 && isBase64 then "sha256-" else
        if len == 64 && isBase64 then "sha384-" else
        if len == 86 && isBase64 then "sha512-" else
        throw "guessSriHash: TODO implement integrity ${builtins.toJSON integrity}"
      );
    in
    (prefix + integrity);

  patchDep = sourceOptions: name: dep:
    /*
      trace: patchDep dep
      {
        "integrity":"sha512-853e636745131719b85650df93d1a3a9af0b0db1c0e2a0884451ec87e14c8b0f4fb911c04805984ece1211ff1235f7869547b780e06939469410f2da9b5e0da6",
        "name":"7zip-bin@npm:~5.1.1",
        "resolved":"7zip-bin@npm:5.1.1",
        "version":"5.1.1"
      }
    */
    #lib.traceSeq { f = "patchDep"; inherit dep; }
    (
    assert (!(dep ? integrity)) ->
      throw "dep.integrity is missing on dep: ${builtins.toJSON dep}";
      /*

        TODO allow user to set missing integrity

        example:

        "tree-sitter@https://github.com/joaomoreno/node-tree-sitter/releases/download/v0.20.0/tree-sitter-0.20.0.tgz":
          version "0.20.0"
          resolved "https://github.com/joaomoreno/node-tree-sitter/releases/download/v0.20.0/tree-sitter-0.20.0.tgz#5679001aaa698c7cddc38ea23b49b9361b69215f"
          dependencies:
            nan "^2.14.0"
            prebuild-install "^6.0.1"

      */
    let
      # TODO remove hash suffix from dep.resolved
      parsedDep = dep // (
        #if dep ? resolved then (
        if dep.resolved != null then (
          # get integrity from resolved
          # example:
          # https://github.com/joaomoreno/node-tree-sitter/releases/download/v0.20.0/tree-sitter-0.20.0.tgz#5679001aaa698c7cddc38ea23b49b9361b69215f
          # -> integrity = 30aa825f11d438671d585bd44e7fd564535fc210
          let
            resolvedParts = lib.splitString "#" dep.resolved;
          in
          rec {
            resolved = builtins.elemAt resolvedParts 0;
            integrity = guessSriHash (builtins.elemAt resolvedParts 1);
          }
        )
        else
        #if dep ? resolution then (
        if dep.resolution != null then (
          {
            resolved = getUrlOfResolution dep.resolution;
            integrity = guessSriHash dep.integrity;
          }
        )
        else
        throw "dep.resolved is missing on dep: ${builtins.toJSON dep}"
      );

      /*
        wtf yarn?
        trace: { body = [ "version: 5.1.1" "resolution: \"7zip-bin@npm:5.1.1\"" "checksum: 853e636745131719b85650df93d1a3a9af0b0db1c0e2a0884451ec87e14c8b0f4fb911c04805984ece1211ff1235f7869547b780e06939469410f2da9b5e0da6" "languageName: node" "linkType: hard" ]; f = "parseBlock resolved"; resolvedRaw = "\"7zip-bin@npm:5.1.1\""; }
        trace: { _f = "makeSourceAttrsV1"; dependency = { integrity = "sha512:853e636745131719b85650df93d1a3a9af0b0db1c0e2a0884451ec87e14c8b0f4fb911c04805984ece1211ff1235f7869547b780e06939469410f2da9b5e0da6"; name = "7zip-bin@npm:~5.1.1"; resolution = "7zip-bin@npm:5.1.1"; resolved = "https://registry.npmjs.org/7zip-bin/-/7zip-bin-5.1.1.tgz"; resolvedOrResolution = "7zip-bin@npm:5.1.1"; version = "5.1.1"; }; name = "7zip-bin@npm:~5.1.1"; }
        building '/nix/store/a47k7n9r7wyxnqxnah32c7b3wmsl8kfc-7zip-bin-5.1.1.tgz.drv'...

        trying https://registry.npmjs.org/7zip-bin/-/7zip-bin-5.1.1.tgz
        error: hash mismatch in fixed-output derivation '/nix/store/a47k7n9r7wyxnqxnah32c7b3wmsl8kfc-7zip-bin-5.1.1.tgz.drv':
                 specified: sha512-hT5jZ0UTFxm4VlDfk9Gjqa8LDbHA4qCIRFHsh+FMiw9PuRHASAWYTs4SEf8SNfeGlUe3gOBpOUaUEPLam14Npg==
                    got:    sha512-sAP4LldeWNz0lNzmTird3uWfFDWWTeg6V/MsmyyLR9X1idwKBWIgt/ZvinqQldJm3LecKEs1emkbquO6PCiLVQ==

        # no. same error with https://registry.yarnpkg.com/
        # -> wrong version?
        trying https://registry.yarnpkg.com/7zip-bin/-/7zip-bin-5.1.1.tgz
        error: hash mismatch in fixed-output derivation '/nix/store/0xlnkp5mq4zlqg2yhc66qqpibf16c81a-7zip-bin-5.1.1.tgz.drv':
                 specified: sha512-hT5jZ0UTFxm4VlDfk9Gjqa8LDbHA4qCIRFHsh+FMiw9PuRHASAWYTs4SEf8SNfeGlUe3gOBpOUaUEPLam14Npg==
                    got:    sha512-sAP4LldeWNz0lNzmTird3uWfFDWWTeg6V/MsmyyLR9X1idwKBWIgt/ZvinqQldJm3LecKEs1emkbquO6PCiLVQ==

        berry/packages/yarnpkg-core/sources/Cache.ts
          const actualChecksum = (!opts.skipIntegrityCheck || !expectedChecksum)
            ? `${actualCacheKey}/${await hashUtils.checksumFile(path)}`
            : expectedChecksum;

        berry/packages/yarnpkg-core/sources/hashUtils.ts
          export async function checksumFile(path: PortablePath, {baseFs, algorithm}: {baseFs: FakeFS<PortablePath>, algorithm: string} = {baseFs: xfs, algorithm: `sha512`}) {
            const fd = await baseFs.openPromise(path, `r`);

            try {
              const CHUNK_SIZE = 65536;
              const chunk = Buffer.allocUnsafeSlow(CHUNK_SIZE);

              const hash = createHash(algorithm);

              let bytesRead = 0;
              while ((bytesRead = await baseFs.readPromise(fd, chunk, 0, CHUNK_SIZE)) !== 0)
                hash.update(bytesRead === CHUNK_SIZE ? chunk : chunk.slice(0, bytesRead));

              return hash.digest(`hex`);
            } finally {
              await baseFs.closePromise(fd);
            }
          }
      */

      # translate resolution to url
      getUrlOfResolution = resolution:
        let
          # "@a/b@npm:1" -> [ "@a/b" "@a/" "b" "npm" "1" ]
          # "a@npm:1" -> [ "a" null "a" "npm" "1" ]
          parts = builtins.match "((@[^@/ ]+/)?([^@/ ]+))@(npm):([^@/ ]+)" resolution;
          pnameFull = builtins.elemAt parts 0;
          pname = builtins.elemAt parts 2;
          host = builtins.elemAt parts 3;
          version = builtins.elemAt parts 4;
          result = (
            # @types/estree@npm:0.0.50 -> https://registry.npmjs.org/@types/estree/-/estree-0.0.50.tgz
            #if host == "npm" then "https://registry.npmjs.org/${pnameFull}/-/${pname}-${version}.tgz"
            if host == "npm" then "https://registry.yarnpkg.com/${pnameFull}/-/${pname}-${version}.tgz"
            else
            throw "getUrlOfResolution: failed to parse resolution ${builtins.toJSON resolution}"
          );
        in
        #lib.traceSeq { _f = "getUrlOfResolution"; inherit resolution result; }
        result;

      src = (
        # FIXME not reached
        #lib.traceSeq { f = "patchDep"; inherit parsedDep; }
        (
        /*
        parsedDep {
          "integrity":"853e636745131719b85650df93d1a3a9af0b0db1c0e2a0884451ec87e14c8b0f4fb911c04805984ece1211ff1235f7869547b780e06939469410f2da9b5e0da6",
          "name":"7zip-bin@npm:~5.1.1",
          "resolved":" \"7zip-bin@npm:5.1.1",
          "version":" 5.1.1"
          }
        */
        #assert builtins.length resolvedParts != 2 ->
        #  throw "unexpected format in resolved '${dep.resolved}'. expected url#hash.";
        # FIXME error: invalid SRI hash
        internal.makeSourceV1 sourceOptions name parsedDep
        )
      );
    in
    dep // {
      resolved = src.resolved;
    }
    );

  patchLockfileText = sourceOptions: lockfile: lockfileText:
    lib.traceSeq (rec {
      _f = "patchLockfileText";
      dep0 = builtins.head lockfile;
      searchStrings0 = dep0.resolvedOrResolution;
    })
    (
    let
      # FIXME error: invalid SRI hash -> fix patchDep
      #patchedDeps = builtins.listToAttrs (map (dep: lib.nameValuePair dep.name (patchDep sourceOptions dep.name dep)) lockfile);
      patchedDeps = builtins.listToAttrs (map (dep:
        #lib.traceSeq { f = "patchLockfileText patchedDeps"; patchDepResult = (patchDep sourceOptions dep.name dep); }
        (lib.nameValuePair dep.name (patchDep sourceOptions dep.name dep)
      )) lockfile);
      searchStrings = map (dep: dep.resolvedOrResolution) lockfile;
      #replaceStrings = map (x: patchedDeps.${x.name}.resolvedOrResolution) lockfile;
      replaceStrings = map (
        dep:
          #lib.traceSeq { f = "patchLockfileText replaceStrings"; inherit dep patchedDeps; }
          patchedDeps.${dep.name}.resolved
      ) lockfile;
    in
    # FIXME patch: resolution: "@babel/generator@npm:7.20.14"
    #lib.traceSeq { _f = "patchLockfileText"; searchStrings0 = builtins.head searchStrings; replaceStrings0 = builtins.head replaceStrings; }
    # FIXME error: dep.integrity is missing on dep: {"name":"7zip-bin@npm:~5.1.1","resolved":"https://registry.npmjs.org/7zip-bin/-/7zip-bin-5.1.1.tgz","version":"5.1.1"}
    /*
    lib.traceSeq rec {
      _f = "patchLockfileText";
      dep0 = builtins.head lockfile;
      searchStrings0 = dep0.resolved;
      replaceStrings0 = patchedDeps.${dep0.name}.resolved;
    }
    */
    (builtins.replaceStrings searchStrings replaceStrings lockfileText)
    );

  # FIXME: deduplicate the code with the npmlock node_modules function
  node_modules =
    { src
    , filterSource ? true
    , sourceFilter ? internal.onlyPackageJsonFilter
    , yarnLockFile ? src + "/yarn.lock"
    , packageJsonFile ? src + "/package.json"
    , buildInputs ? [ ]
    # TODO sort same as in internal
    , nodejs ? default_nodejs
    , sourceOverrides ? { }
    , githubSourceHashMap ? { }
    , symlinkNodeModules ? false
    , ...
    }@args:

    /*
    { src ? /var/empty
    , packageJson ? src + "/package.json"
    , packageLockJson ? src + "/package-lock.json"
    , buildInputs ? [ ]
    , nativeBuildInputs ? [ ]
    , nodejs ? default_nodejs
    , preBuild ? ""
    , postBuild ? ""
    , preInstallLinks ? null
    , passthru ? { }
    , ...
    }@args:
    */

    let
      nodeHostCpuNames = internal.nodeHostCpuNames;
      nodeHostOsNames = internal.nodeHostOsNames;

      sourceOptions = {
        sourceHashFunc = internal.sourceHashFunc githubSourceHashMap;
        inherit sourceOverrides symlinkNodeModules nodeHostCpuNames nodeHostOsNames;
        nodejs = if symlinkNodeModules then (nodejs-hide-symlinks.override { inherit nodejs; }) else nodejs;
        packagesVersions = lockfile.packages or { };
      };

      lockfileText = removePreamble (builtins.readFile yarnLockFile);

      lockfile = parseLockFileText lockfileText;

      #packagefile = readPackageLikeFile packageJson;
      #patchedLockfileData = patchLockfile sourceOptions lockfile;

      packageJson = builtins.fromJSON (builtins.readFile packageJsonFile);
      #patchedLockfile = writeText "yarn.lock" (patchLockfileText sourceOptions lockfile lockfileText);
      patchedLockfile =
        /*
        trace: lockfile [
          {
            "integrity":"sha512-853e636745131719b85650df93d1a3a9af0b0db1c0e2a0884451ec87e14c8b0f4fb911c04805984ece1211ff1235f7869547b780e06939469410f2da9b5e0da6",
            "name":"7zip-bin@npm:~5.1.1",
            "resolved":"7zip-bin@npm:5.1.1",
            "version":"5.1.1"
          }
        ]
        */
        #lib.traceSeq { f = "node_modules"; inherit lockfile; }
        # FIXME not reached -> fix patchLockfileText
        #lib.traceSeq { f = "node_modules"; lockfileText2 = (patchLockfileText sourceOptions lockfile lockfileText); }
        #lib.traceSeq { _f = "node_modules"; inherit lockfileText; }
        (
        writeText "yarn.lock" (patchLockfileText sourceOptions lockfile lockfileText)
        );
    in
    stdenv.mkDerivation (args // {
      pname = packageJson.name;
      version = packageJson.version;
      inherit src;

      buildInputs = [ yarn nodejs ] ++ buildInputs;

      propagatedBuildInputs = [ nodejs ];

      setupHooks = [ ./set-paths.sh ];

      postPatch = ''
        ln -sf ${patchedLockfile} yarn.lock
      '';

      buildPhase = ''
        runHook preBuild

        head -n100 yarn.lock
        exit 1

        # force yarn to create node_modules/ not .yarn/
        # https://github.com/yarnpkg/yarn/issues/5500
        # https://yarnpkg.com/features/pnp
        echo "nodeLinker: node-modules" >.yarnrc.yml

        export HOME=$TMP
        yarn config set --home enableTelemetry 0
        #yarn install --offline # Unsupported option name ("--offline")
        #yarn ci # Usage Error: Couldn't find the node_modules state file - running an install might help (findPackageLocation)
        yarn install
        test -d node_modules/.bin && patchShebangs node_modules/.bin

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir $out

        if test -d node_modules; then
          if [ $(ls -1 node_modules | wc -l) -gt 0 ] || [ -e node_modules/.bin ]; then
            mv node_modules $out/
            if test -d $out/node_modules/.bin; then
              ln -s $out/node_modules/.bin $out/bin
            fi
          fi
        fi
        runHook postInstall
      '';

      passthru.nodejs = nodejs;
    });
in
{
  inherit splitBlocks parseBlock unquote parseLockFileText patchLockfileText patchDep node_modules;
}
