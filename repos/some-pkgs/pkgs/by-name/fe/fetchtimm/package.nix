{ lib, runCommand, python3Packages }:
{ name, outputHash, modelNames, ... }@args:

runCommand "name"
  ({
    nativeBuildInputs = [
      (python3Packages.python.withPackages (ps: with ps; [
        timm
        torch
        torchvision
      ]))
    ] ++ (args.nativeBuildInputs or [ ]);
    inherit outputHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  } // (builtins.removeAttrs args [ "nativeBuildInputs" ]))
  ''
    export HUGGINGFACE_HUB_CACHE=$out/data/huggingface/
    mkdir -p "$HUGGINGFACE_HUB_CACHE"
    python << EOF
    import timm
    ${lib.concatStringsSep ''\n'' (map (name:
    ''timm.create_model("${name}", pretrained=True)'')
      modelNames)}
    EOF
  ''
