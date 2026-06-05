{
  applyPatches,
  jq,
  moreutils,
  nur,
}:
nur.overrideAttrs {
  src = applyPatches {
    inherit (nur) src;

    nativeBuildInputs = [
      jq
      moreutils
    ];

    # delete all hashes & revs:
    # nur defaults to `builtins.fetchGit`;
    # by removing all references to `revision` (= { rev = ...; sha256 = ...;}),
    # the resulting repo expressions fetch `HEAD` each time, unlocked.
    #
    # note that `nur.repo-sources` uses nixpkgs `fetchgit`, so that attribute
    # will fail to evaluate.
    postPatch = ''
      substituteInPlace lib/repoSource.nix \
        --replace-fail 'inherit (revision)' '# inherit (revision)'
    '';
  };
}
