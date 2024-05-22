# Helper library to parse yarn.lock files that are some custom format and not just JSON :(
{ lib
, internal
, stdenv
, nodejs
, yarn
, writeText
}:

let
  default_nodejs = nodejs;

  # Description: Split a file into logicla blocks of "dependencies", on dependency per block.
  # Type: String -> [ String ]
  splitBlocks = text:
    assert builtins.typeOf text != "string" -> throw "Expected the argument text to be of type string.";
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
    assert builtins.typeOf text != "string" -> throw "Expected the argument text to be of type string.";
    let
      s = if lib.hasPrefix "\"" text then builtins.substring 1 (builtins.stringLength text) text else text;
    in
    if s != "" then
      if lib.hasSuffix "\"" s then builtins.substring 0 ((builtins.stringLength s) - 1) s else s else s;


  # Description: Parse a single "block" from the lock file into an attrset
  # Type: String -> Attrset
  parseBlock = block:
    let
      getField = fieldName: prefixes: body:
        let
          cutPrefix = prefix: x: builtins.substring (builtins.stringLength prefix) (builtins.stringLength x) x;
          ls = lib.flatten (map (prefix: map (cutPrefix prefix) (builtins.filter (lib.hasPrefix prefix) body)) prefixes);
          line = assert builtins.length ls == 0 -> throw "no ${fieldName} line found in block for package ${name}"; builtins.head ls;
        in
        line;

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

      version = unquote (getField "version" ["version "] body);
      resolved = unquote (getField "resolved" ["resolved "] body);
      integrity = getField "integrity" ["integrity "] body;

      dependencies = parseDependencies body;
    in
    ({
      inherit name version resolved;
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

  parseFile = filePath:
    let
      content = removePreamble (builtins.readFile filePath);
    in
    map parseBlock (builtins.filter (block: block != "") (splitBlocks content));

  # guess hash type
  guessSriHash = integrityPadded:
    let
      integrity = builtins.head (
        let parts = builtins.match "([^=]+)=*" integrityPadded; in
        assert (parts != null) ->
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

  patchDep = name: dep:
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
      resolvedParts = lib.splitString "#" dep.resolved;
      # TODO remove hash suffix from dep.resolved
      parsedDep = dep // {
        resolved = builtins.elemAt resolvedParts 0;
        # get integrity from resolved
        # example:
        # https://github.com/joaomoreno/node-tree-sitter/releases/download/v0.20.0/tree-sitter-0.20.0.tgz#5679001aaa698c7cddc38ea23b49b9361b69215f
        # -> integrity = 30aa825f11d438671d585bd44e7fd564535fc210
        #integrity = guessSriHash (builtins.elemAt resolvedParts 1);
      };
      sourceOptions = { nodejs = default_nodejs; }; # TODO expose
      src = (
        lib.traceSeq { inherit parsedDep; }
        (
        assert builtins.length resolvedParts != 2 ->
          throw "unexpected format in resolved '${dep.resolved}'. expected url#hash";
        internal.makeSource sourceOptions name parsedDep
        )
      );
    in
    dep // {
      resolved = src.resolved;
    };

  patchFile = filePath:
    let
      parsedFile = parseFile filePath;
      patchedDeps = builtins.listToAttrs (map (x: lib.nameValuePair x.name (patchDep x.name x)) parsedFile);

      searchStrings = map (x: x.resolved) parsedFile;
      replaceStrings = map (x: patchedDeps.${x.name}.resolved) parsedFile;

      contents = builtins.readFile filePath;
    in
    builtins.replaceStrings searchStrings replaceStrings contents;

  # FIXME: deduplicate the code with the npmlock node_modules function
  node_modules =
    { src
    , filterSource ? true
    , sourceFilter ? internal.onlyPackageJsonFilter
    , yarnLockFile ? src + "/yarn.lock"
    , packageJsonFile ? src + "/package.json"
    , buildInputs ? [ ]
    , nodejs ? default_nodejs
    , ...
    }@args:
    let
      packageJson = builtins.fromJSON (builtins.readFile packageJsonFile);
      patchedLockfile = writeText "yarn.lock" (patchFile yarnLockFile);
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
        yarn install --offline
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
  inherit splitBlocks parseBlock unquote parseFile patchFile patchDep node_modules;
}
