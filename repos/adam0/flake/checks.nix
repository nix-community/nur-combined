_: {
  perSystem = {pkgs, ...}: {
    checks.updater-tests =
      pkgs.runCommand "updater-tests" {
        nativeBuildInputs = [pkgs.python3];
      } ''
        cp -r --no-preserve=mode ${../.} source
        cd source
        python3 -m unittest updater.test_dependency_hash updater.test_github_release updater.test_manifest updater.test_source_hash updater.test_tangled
        touch $out
      '';
  };
}
