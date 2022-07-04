{nixpkgs, ...} @ args: let
  inherit (builtins) isAttrs isPath map;
  inherit (nixpkgs.lib.attrsets) recursiveUpdate;
  inherit (nixpkgs.lib.lists) foldl;
  inherit (nixpkgs.lib.trivial) isFunction;

  # Apply `recursiveUpdate` to the list of attribute sets, producing a merged
  # attribute set.
  #
  recursiveUpdateMany = list: foldl recursiveUpdate {} list;

  # Import a chunk from one of supported types, producing a corresponding
  # attribute set.
  #
  # Possible chunk types:
  #   - path - imported with `import chunk args`;
  #   - function - gets called as `chunk args`;
  #   - attribute set - returned as is.
  #
  importChunk = args: chunk:
    if isPath chunk
    then import chunk args
    else if isFunction chunk
    then chunk args
    else if isAttrs chunk
    then chunk
    else throw "Unknown chunk type: ${chunk}";

  # Import all chunks in the list, producing a list of corresponding attribute
  # sets.
  #
  importChunks = args: list: map (importChunk args) list;

  # Import all chunks in the list and merge them with `recursiveUpdateMany`,
  # producing a merged attribute set.
  #
  mergeChunks = args: list: recursiveUpdateMany (importChunks args list);
in
  mergeChunks args [
    {
      attrsets = {inherit recursiveUpdateMany;};
      chunks = {inherit importChunk importChunks mergeChunks;};
    }
    ./attrsets.nix
    ./ci.nix
    ./ci-data.nix
    ./lists.nix
  ]
