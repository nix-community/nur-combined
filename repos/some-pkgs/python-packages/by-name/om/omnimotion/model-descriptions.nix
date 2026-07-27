{ lib
, examples
, python
, runCommand
}:

lib.genAttrs
  (builtins.attrNames examples)
  (name:
  let example = examples.${name}.package;
  in
  runCommand "model.txt"
  {
    nativeBuildInputs = [ (python.withPackages (ps: [ ps.omnimotion ])) ];
    checkpoint = "${example}/model*.pth";
  }
    ''
      python << EOF | tee $out
      import glob
      import os
      import torch
      from pprint import pprint

      def describe(x):
        if isinstance(x, dict):
          return {name: describe(y) for name, y in x.items()}
        elif isinstance(x, (list, tuple)):
          return [describe(y) for y in x]
        elif isinstance(x, (int, float, str)):
          return x
        elif isinstance(x, torch.Tensor):
          desc = {
            "dtype": str(x.dtype),
            "shape": tuple(x.shape),
          }
          if len(x) > 0:
            desc = {
              **desc,
              "min": x.min().item(),
              "max": x.max().item(),
              "mean": x.mean().item(),
              "std": x.std().item(),
            }
          return desc
        else:
          return f"{type(x)}"

      for f in glob.glob(os.environ["checkpoint"]):
        weights = torch.load(f, map_location="cpu")
        del weights["optimizer"] # too much noise
        print(f"[{f}]")
        pprint(describe(weights))
      EOF
    '')
