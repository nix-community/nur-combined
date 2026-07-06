{ }:
let
  name = "source";
  src = builtins.path {
    inherit name;
    path = ../../../.;
    filter = path: type:
      let
        name = baseNameOf path;
      in !(
        # mimic .gitignore
           (path == toString ../../../.ck)
        || (path == toString ../../../.coderag)
        || (path == toString ../../../.work)
        || (path == toString ../../../build)
        || (name == "result")
        || (builtins.match "^result-.+$" name != null)
        || (builtins.match "^core\\.[0-9]+$" name != null)
        # omit files known to be irrelevant to this specific eval
        || (path == toString ../../../.git)
        || (path == toString ../../../.gitignore)
      )
    ;
  };
  tree = fetchTree {
    type = "path";
    path = src;
  };
in
  # pseudo-derivation to support `nix-build sane-nix-files`.
  # it's fixed-output derivation. internally, nix builds it like this:
  # 1. compute `outPath`
  # 1.1. `outPath` is a function of `outputHash = tree.narHash`
  #      so realize the non-FOD `fetchTree` call above.
  # 2. check if the derivation needs to be built.
  # 2.1. sees that `outPath` exists in the store -> nothing to do.
  derivation {
    inherit name;
    system = "fake";
    builder = "false";
    outputHashMode = "recursive";
    outputHash = assert (tree.outPath == src); tree.narHash;
    # shouldn't be required, but hopefully guards against anything too confusing, especially future changes to attr eval order in nix.
    preferLocalBuild = true;
    allowSubstitutes = false;
    # passthru for convenience
    inherit tree;
    inherit src;
  }
  // {
    # micro optimization (?):
    # - any perf benefit is not measurable.
    # - avoids a `fetching path input 'path:/nix/store/...` message on every eval though.
    #
    # `import sane-nix-files` acts as shorthand for `import sane-nix-files.outPath`;
    # we know this is equivalent to `src`, but nix would need to evaluate the `fetchTree`
    # to see this for itself, which probably requires hashing the contents of `src`,
    # or at least printing an annoying message.
    outPath = src;
  }
