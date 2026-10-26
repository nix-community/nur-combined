_: {
  perSystem = {pkgs, ...}: {
    checks.updater-tests =
      pkgs.runCommand "updater-tests" {
        nativeBuildInputs = [pkgs.python3];
      } ''
        cp -r --no-preserve=mode ${../.} source
        cd source
        python3 -m unittest discover -s updater -t .
        touch $out
      '';
  };
}
