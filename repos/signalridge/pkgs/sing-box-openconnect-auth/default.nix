{
  lib,
  writeShellApplication,
  buf,
  jq,
  coreutils,
}:
writeShellApplication {
  name = "sing-box-openconnect-auth";
  runtimeInputs = [
    buf
    jq
    coreutils
  ];
  text = lib.replaceStrings [ "@lib@" ] [ "${./.}" ] (builtins.readFile ./openconnect-auto.sh);
  meta = {
    description = "Connect an external cookie authenticator to sing-box OpenConnect";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "sing-box-openconnect-auth";
  };
}
