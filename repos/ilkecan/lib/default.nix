{
  lib',
  lib,
  pkgs,
  ...
}:

let
  inherit (lib')
    INFINITY
    importTree
    mkAbsolutePath
    storePathName
    ;

  inherit (lib)
    assertMsg
    attrNames
    bitXor
    concatMapStrings
    concatStringsSep
    convertHash
    filterAttrs
    fixedWidthString
    fromHexString
    genList
    hasSuffix
    hashString
    id
    isPath
    isType
    length
    listToAttrs
    mapAttrs'
    mapAttrsToListRecursive
    nameValuePair
    pathExists
    readDir
    stringLength
    substring
    toHexString
    ;

  inherit (pkgs)
    callPackage
    nushell
    writeTextFile
    ;
in
{

  INFINITY = 1.0e308 * 2;

  callPackage' = fn: callPackage fn { };

  flakeInputStorePath =
    let
      # Nix reduces a SHA-256 digest to the 160-bit hash used in store paths by
      # XOR-folding the final 12 bytes into the first 12 bytes.
      truncateSha256To160 =
        hash:
        assert stringLength hash == 64;
        concatMapStrings (
          index:
          # `toHexString` drops leading zeroes, so restore each 32-bit word
          fixedWidthString 8 "0" (
            toHexString (
              bitXor (fromHexString (substring (index * 8) 8 hash)) (
                if index < 3 then fromHexString (substring ((index + 5) * 8) 8 hash) else 0
              )
            )
          )
        ) (genList (x: x) 5);
      # Pure evaluation cannot obtain the configured store directory.
      storeDir = "/nix/store";
    in
    { narHash, ... }:
    let
      narHashHex = convertHash {
        hash = narHash;
        toHashFormat = "base16";
      };

      fingerprint = "source:sha256:${narHashHex}:${storeDir}:source";

      # `convertHash` needs an algorithm to infer the hash length. SHA-1 is
      # used only because it is also 160 bits.
      storeHash = convertHash {
        hash = truncateSha256To160 (hashString "sha256" fingerprint);
        hashAlgo = "sha1";
        toHashFormat = "nix32";
      };
    in
    "${storeDir}/${storeHash}-source";

  flattenAttrs =
    sep: attrs:
    listToAttrs (
      mapAttrsToListRecursive (path: value: nameValuePair (concatStringsSep sep path) value) attrs
    );

  importTree =
    {
      root,

      depth ? INFINITY,
      entryFilter ? (_: _: true),
      # NOTE: Prefer `importApply` over bare `import` when a module expression
      # is required. If there is no extra arguments to be passed, file path
      # (`importFn = id`) is also preferable to `import`.
      # https://noogle.dev/f/lib/modules/importApply
      importFn ? import,
      normalizeNameFn ? id,
    }:
    let
      importFile = path: importFn (mkAbsolutePath root path);
      importDir =
        path:
        let
          entries = filterAttrs entryFilter (readDir path);
          result = mapAttrs' (
            name: type:
            let
              name' = normalizeNameFn name;
              value =
                if type == "directory" then
                  importTree {
                    root = mkAbsolutePath root name;
                    depth = depth - 1;
                    inherit normalizeNameFn importFn;
                  }
                else
                  importFile name;
            in
            nameValuePair name' value
          ) entries;
        in
        assert assertMsg (
          length (attrNames entries) == length (attrNames result)
        ) "importTree: normalized names collide in ${toString path}";
        result;
    in
    if depth <= 0 then importFile root else importDir root;

  importsFromDirectory =
    dir:
    let
      isImportable =
        name: type:
        if type == "directory" then
          pathExists (dir + "/${name}/default.nix")
        else
          hasSuffix ".nix" name && name != "default.nix";
    in
    map (name: dir + "/${name}") (attrNames (filterAttrs isImportable (readDir dir)));

  isFlake = isType "flake";

  isPatchedFlakeInput = x: storePathName x.outPath != "source";

  mkAbsolutePath =
    root: path:
    if isPath path then
      path
    else
      let
        path' = toString path;
        firstChar = substring 0 1 path';
      in
      if firstChar == "/" then path' else root + "/${path'}";

  storePathName = path: substring 33 (-1) (baseNameOf path);

  writeNushellScript =
    let
      shell = "${nushell}/${nushell.shellPath}";
    in
    name: text:
    writeTextFile {
      inherit name;
      executable = true;

      text = ''
        #!${shell}
        ${text}
      '';

      checkPhase = ''
        target=$target ${shell} --no-config-file --no-std-lib --commands 'if not (nu-check --debug $env.target) { exit 1 }'
      '';
    };
}
