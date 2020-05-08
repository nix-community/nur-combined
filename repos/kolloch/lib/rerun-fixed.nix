{ pkgs, lib }:

rec {
  /* Creates a fixed output derivation that reruns if any of its inputs change.

     Type: rerunOnChange -> attr set -> derivation -> derivation

     Example:
      let myFixedOutputDerivation = pkgs.stdenv.mkDerivation {
        # ...
        outputHash = "sha256:...";
        outputHashMode = "recursive";
      };
      in
      nur.repos.kolloch.lib.rerunOnChange {} myFixedOutputDerivation;

     The args attribute set:
       preOverrideAttrs - use this to overwrite attributes before the input
                          calculation. This allows you to ignore changes in some
                          attributes.

                          E.g. preOverrideAttrs = attrs: { mirrors = null; }

     Usually, fixed output derivations are only rerun if their name or hash
     changes (i.e. when their output path changes). This makes the derivation
     definition irrelevant if the output is in the cache.

     With this helper, you can make sure that the commands that are specified
     where at least ran once -- with the exact versions of the buildInputs that
     you specified. It does so by putting a hash of all the inputs into the
     name.

     ## Implementation

     Getting the hash is easy, because nix already does that work
     for us when creating the output paths for non-fixed output derivations.
     Therefore, if we create a non-fixed output derivation with the same inputs,
     the hash in the output path should change with every change in inputs.
   */
  rerunOnChange = { preOverrideAttrs ? attrs: attrs } @ args: fixedOutputDerivation:
    assert (lib.assertMsg
      (fixedOutputDerivation ? outputHash)
      "rerunOnChange expects a fixedOutputDerivation");
    assert (lib.assertMsg
      (fixedOutputDerivation ? overrideAttrs)
      "rerunOnChange expects a derivation overridable with overrideAttrs");

    let
      # The name of the original derivation.
      name = fixedOutputDerivation.name or "fixed";

      # A hash that includes all inputs of the fixedOutputDerivation.
      inputsHash =
        let
          unfixedDerivation = fixedOutputDerivation.overrideAttrs(attrs:
            let preAttrs = preOverrideAttrs attrs;
            in preAttrs // {
              outputHash = null;
              outputHashAlgo = null;
              outputHashMode = null;
            }
          );
          outputPath = builtins.unsafeDiscardStringContext unfixedDerivation.outPath;
        in builtins.substring 11 32 outputPath;

    in
      fixedOutputDerivation.overrideAttrs (attrs: {
        # The name will change if any of the inputs change.
        name = "${inputsHash}_${name}";
      }) // {
        # Overriding will also change the name accordingly again.
        overrideAttrs =
          f: rerunOnChange args (fixedOutputDerivation.overrideAttrs f);
      };
}

