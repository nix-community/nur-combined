{
  stdenv,
  roundcube-oidc-unwrapped,
  writeText,
  runCommand,
  lib,
  php,
  configText ? "",
}:

let
  inherit (lib) getExe optionalString;

  config = writeText "roundcube-oidc-config.php" configText;
  configChecked = runCommand "roundcube-oidc-config-checked" { } ''
    ${getExe php} -l ${config}
    cp ${config} $out
  '';
in
stdenv.mkDerivation {
  pname = "roundcube-oidc";
  inherit (roundcube-oidc-unwrapped) version meta;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/plugins/roundcube_oidc
    ln -s ${roundcube-oidc-unwrapped}/plugins/roundcube_oidc/* $out/plugins/roundcube_oidc

    ${optionalString (configText == "") ''
      cp $out/plugins/roundcube_oidc/config.inc.php.dist $out/plugins/roundcube_oidc/config.inc.php
    ''}

    ${optionalString (configText != "") ''
      cp ${configChecked} $out/plugins/roundcube_oidc/config.inc.php
    ''}
  '';
}
