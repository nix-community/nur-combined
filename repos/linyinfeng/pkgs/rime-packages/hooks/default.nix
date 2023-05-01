{ makeSetupHook }:

{
  rimeDataBuildHook = makeSetupHook
    {
      name = "rime-data-build-hook.sh";
      substitutions = { };
    } ./rime-data-build-hook.sh;
}
