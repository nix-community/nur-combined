{ makeSetupHook, libfaketime }:

{
  rimeDataBuildHook = makeSetupHook {
    name = "rime-data-build-hook.sh";
    propagatedBuildInputs = [
      libfaketime
    ];
    substitutions = { };
  } ./rime-data-build-hook.sh;
}
