{ hponcfg-unwrapped
, buildFHSUserEnv
, callPackage
#, openssl
#, busybox
, writeScript
}:
buildFHSUserEnv {
  name = "hponcfg-wrapped";
  inherit (hponcfg-unwrapped) meta;

  targetPkgs = pkgs: with pkgs; [
    openssl.out
    busybox
    hponcfg-unwrapped
  ];

  multiPkgs = null;

  runScript = writeScript "hponcfg-script" "${hponcfg-unwrapped}/bin/hponcfg";
}
