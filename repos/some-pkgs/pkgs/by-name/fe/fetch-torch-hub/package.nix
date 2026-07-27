{ lib, runCommand, python3Packages }:
{ hash, urls, ... }@args:

assert builtins.isList urls;

runCommand "weights"
  ({
    nativeBuildInputs = [
      (python3Packages.python.withPackages (ps: with ps; [
        torch
        torchvision
      ]))
    ] ++ (args.nativeBuildInputs or [ ]);
    outputHash = hash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";

    urls = builtins.toJSON urls;
    passAsFile = [ "urls" ];
  } // (builtins.removeAttrs args [ "hash" "urls" "nativeBuildInputs" ]))
  ''
    export TORCH_HOME=$out/data/torch
    export TORCH_HUB=$TORCH_HOME/hub
    export HUGGINGFACE_HUB_CACHE=$out/data/huggingface/

    mkdir -p "$HUGGINGFACE_HUB_CACHE" "$TORCH_HOME" "$TORCH_HUB"

    python << EOF
    import ssl
    ssl._create_default_https_context = ssl._create_unverified_context

    import json
    import os
    import torch.hub

    with open(os.environ["urlsPath"], "r") as f:
      urls = json.load(f)
    
    for url in urls:
      torch.hub.load_state_dict_from_url(url=url, map_location="cpu")
      break
    EOF
  ''

