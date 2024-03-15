{
  pkgs,
  lib,
  sources,
  python3,
  chromedriver,
  undetected-chromedriver,
  ...
}:
let
  py = python3.withPackages (
    p: with p; [
      requests
      selenium
      websockets
      undetected-chromedriver
    ]
  );

  specSystem =
    if pkgs.system == "x86_64-linux" then
      "linux64"
    else if pkgs.system == "x86_64-darwin" then
      "mac-x64"
    else if pkgs.system == "aarch64-darwin" then
      "mac-arm64"
    else
      throw "Unsupported system";
in
chromedriver.overrideAttrs (old: {
  pname = "undetected-chromedriver-bin";

  postPatch = ''
    export HOME=$(pwd)
    export CHROMEDRIVER=$(pwd)/chromedriver-${specSystem}/chromedriver

    ls -alh

    ${py}/bin/python <<EOF
    from undetected_chromedriver.patcher import Patcher
    exit(not Patcher(executable_path="''${CHROMEDRIVER}").patch())
    EOF

    # Make sure chromedriver is properly patched
    grep "undetected chromedriver" "''${CHROMEDRIVER}"
  '';

  installPhase =
    (builtins.replaceStrings [ "$out/bin/chromedriver" ] [
      "$out/bin/undetected_chromedriver"
    ] old.installPhase)
    # Trick undetected-chromedriver python library into thinking that chromedriver is patched
    + ''
      echo "# undetected chromedriver" >> $out/bin/undetected_chromedriver
    '';

  meta = old.meta // {
    description = "Chromedriver with undetected-chromedriver patch";
  };
})
