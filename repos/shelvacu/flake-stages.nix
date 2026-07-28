vacuFlakeInputs:
let
  inherit (vacuFlakeInputs.nixpkgs-lib) lib;
  vaculib = import ./vaculib { inherit lib; };
  stages = vaculib.stagedMake { stageNamePrefix = "vacuStage_"; } {
    a = {
      inherit lib vaculib vacuFlakeInputs;
      vacuRoot = ./.;
      flakeOverlays = map (name: vacuFlakeInputs.${name}.overlays.default) [
        "sm64baserom"
        "most-winningest"
        "pynixos"
      ];
    };
    b =
      prevStage:
      let
        vaculibArgs = { inherit (prevStage) lib vaculib; };
      in
      {
        vacuModules = import ./modules vaculibArgs;
        plainOverlays = import ./overlays vaculibArgs;
      };
    c =
      prevStage:
      let
        inherit (prevStage) vacuRoot;
      in
      {
        dnsEval =
          let
            inner = lib.evalModules {
              modules = [
                /${vacuRoot}/common
                /${vacuRoot}/dns
              ];
              specialArgs = lib.attrsets.disjointUnionOf prevStage {
                inherit (prevStage.vacuFlakeInputs) dns;
                vacuModuleType = "dns";
              };
            };
          in
          inner.config.vacu.withAsserts inner;
      };
  };
in
"*TODO*"
