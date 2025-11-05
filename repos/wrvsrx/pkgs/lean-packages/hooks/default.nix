{ makeSetupHook }:

{
  lakeSetupHook = makeSetupHook {
    name = "lake-setup-hook";
    substitutions = {
      lakeConfigure = "${./lake-configure.lean}";
    };
  } ./lake-setup-hook.sh;
}
