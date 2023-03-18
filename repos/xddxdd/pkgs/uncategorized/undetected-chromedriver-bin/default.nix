{
  lib,
  sources,
  python3,
  chromedriver,
  undetected-chromedriver,
  ...
}: let
  py = python3.withPackages (p:
    with p; [
      requests
      selenium
      websockets
      undetected-chromedriver
    ]);
in
  chromedriver.overrideAttrs (old: {
    pname = "undetected-chromedriver-bin";

    postPatch = ''
      export HOME=$(pwd)

      ${py}/bin/python <<EOF
      from undetected_chromedriver.patcher import Patcher
      exit(not Patcher(executable_path="chromedriver").patch())
      EOF

      # Make sure chromedriver is properly patched
      grep "undetected chromedriver" chromedriver
    '';

    installPhase =
      (builtins.replaceStrings
        ["$out/bin/chromedriver"] ["$out/bin/undetected_chromedriver"]
        old.installPhase)
      # Trick undetected-chromedriver python library into thinking that chromedriver is patched
      + ''
        echo "# undetected chromedriver" >> $out/bin/undetected_chromedriver
      '';

    meta =
      old.meta
      // {
        description = "Chromedriver with undetected-chromedriver patch";
      };
  })
