{ lib, vaculib, ... }: {
  stagedMake =
    {
      stageNamePrefix ? "stage",
      ...
    }:
    stages:
    lib.pipe stages [
      lib.attrsToList
      (lib.flip builtins.foldl'
        {
          stages = { };
          combined = { };
        }
        (
          prevData: stage:
          let
            thisStage =
              builtins.addErrorContext
                "while evaluating stage `${lib.strings.escapeNixIdentifier stage.name}` in vaculib.stagedMake"
                (if builtins.isAttrs stage.value then stage.value else stage.value prevData.combined);
            thisStageAttr = {
              "${stageNamePrefix}${stage.name}" = thisStage;
            };
          in
          {
            stages = prevData.stages // thisStageAttr;
            combined = vaculib.unionOfDisjointList [
              prevData.combined
              thisStageAttr
              thisStage
            ];
          }
        )
      )
    ];
}
