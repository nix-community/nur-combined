{ pkgs, lib }:

rec {
  /* Creates a fixed output derivation that reruns if any of its inputs change.

     Type: rerunFixedDerivationOnChange -> derivation -> derivation

     Example:
      let myFixedOutputDerivation = pkgs.stdenv.mkDerivation {
        # ...
        outputHash = "sha256:...";
        outputHashMode = "recursive";
      };
      in
      nur.repos.kolloch.lib.rerunFixedDerivationOnChange myFixedOutputDerivation;

     Usually, fixed output derivations are only rerun if their name or hash
     changes (i.e. when their output path changes). This makes the derivation
     definition irrelevant if the output is in the cache.

     With this helper, you can make sure that the commands that are specified
     where at least ran once -- with the exact versions of the buildInputs that
     you specified. It does so by putting a hash of all the inputs into the
     name.

     Caveat: It uses "import from derivation" under the hood. See implementation
     for an explanation why.

     Implementation

     Getting the hash is easy, in principle, because nix already does that work
     for us when creating the output paths for non-fixed output derivations.
     Therefore, if we create a non-fixed output derivation with the same inputs,
     the hash in the output path should change with every change in inputs.
     Unfortunately, we cannot use parts of the output path in the name of our
     derivation directly.

     Nix prevents this because supposedly it is not what you want. I don't think
     that it is actually problematic in principle.

     To work around this, I use an import-from-derivation call to get the output
     path. The disadvantage is that all the dependencies of your fixed output
     derivation will be build in the eval phase.
   */
  rerunFixedDerivationOnChange = fixedOutputDerivation:
    assert (lib.assertMsg
      (fixedOutputDerivation ? outputHash)
      "rerunOnChangedInputs expects a fixedOutputDerivation");

    let
      # The name of the original derivation.
      name = fixedOutputDerivation.name or "fixed";

      # A hash that includes all inputs of the fixedOutputDerivation.
      #
      # Creates a derivation that has all the same inputs and
      # simply outputs it's output path.
      #
      # If we could simply access the output path from nix
      # and use it as a part of the name, this would be much easier.
      inputsHash =
        let
          # Args to rename.
          renameArgs = [ "builder" "args" ];
          renamedArgs =
            let declash = attrName:
                  if fixedOutputDerivation ? attrName
                  then declash "${attrName}_"
                  else attrName;
                copyName = attrName: "original_${declash attrName}";
                copy = attrName:
                  {
                    name = copyName attrName;
                    value = fixedOutputDerivation."${attrName}";
                  };
                copies = builtins.map copy renameArgs;
            in
            builtins.listToAttrs copies;
          # Args to replace with null
          nullArgs = renameArgs ++ [ "outputHash" "outputHashAlgo" "outputHashMode" ];
          nulledArgs =
            let nullMe = name:
                  {
                    inherit name;
                    value = null;
                  };
                nulled = builtins.map nullMe nullArgs;
            in
            builtins.listToAttrs nulled;
          outputPathBuilderArgs =
            assert builtins.isAttrs renamedArgs;
            assert builtins.isAttrs nulledArgs;
            renamedArgs // nulledArgs // {
              name = "outpath-for-${name}";
              builder = "${pkgs.bash}/bin/bash";
              args = ["-c" "set -x; echo $out > $out" ];
            };
          outputPathBuilder =
            assert builtins.isAttrs outputPathBuilderArgs;
            if fixedOutputDerivation ? overrideAttrs
            then fixedOutputDerivation.overrideAttrs (attrs: outputPathBuilderArgs)
            else fixedOutputDerivation.overrideDerivation (attrs: outputPathBuilderArgs);
          outputPath =
            assert lib.isDerivation outputPathBuilder;
            builtins.readFile outputPathBuilder;
        in builtins.substring 11 32 outputPath;

      # This is the basic idea: Add the inputsHash to the name
      # to force a rebuild whenever the inputs change.
      nameWithHash = { name = "${inputsHash}_${name}"; };

      # Make "overrideAttrs" and "overrideDerivation" work as expected.
      # That means that we need to keep overriding the name.
      overrideAttrs = f: rerunFixedDerivationOnChange (fixedOutputDerivation.overrideAttrs f);
      overrideDerivation = f: rerunFixedDerivationOnChange (fixedOutputDerivation.overrideDerivation f);
    in
      if fixedOutputDerivation ? overrideAttrs
      then
        (fixedOutputDerivation.overrideAttrs (attrs: nameWithHash))
        // { inherit overrideAttrs overrideDerivation; }
      else
        (fixedOutputDerivation.overrideDerivation (attrs: nameWithHash))
        // { inherit overrideDerivation; };
}

