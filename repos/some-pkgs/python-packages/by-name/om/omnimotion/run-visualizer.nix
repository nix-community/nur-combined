{ lib
, runCommand
, python
}:

let
  f =
    { checkpoint, dataDir, maskPath ? null }@viz-args:
    runCommand "omnimotion-viz-results"
      {
        nativeBuildInputs = [ (python.withPackages (ps: [ ps.omnimotion ])) ];
        requiredSystemFeatures = [ "cuda" ];
        passthru = { inherit viz-args; };
      }
      ''
        omnimotion-viz-default \
          --ckpt_path "${checkpoint}" \
          --data_dir "${dataDir}" \
          ${lib.optionalString (maskPath != null) ''--foreground_mask_path "${maskPath}"''} \
          --save_dir $out
      '';
in
lib.makeOverridable f
