{ makeSetupHook }:

{
  lakeSetupHook = makeSetupHook {
    name = "lake-setup-hook";
    substitutions = {
      lakeConfigure = "${./lake-configure.lean}";
      lakeBuild = "${./lake-build.lean}";
    };
  } ./lake-setup-hook.sh;
}
