{
  buildLua,  #< part of the mpvScripts scope
  lib,
  sane-cast,
  xdg-terminal-exec,
}:
buildLua {
  pname = "sane_cast";
  version = "0.1-unstable";
  src = ./.;

  preInstall = ''
    mkdir sane_cast
    mv main.lua sane_cast
  '';

  passthru.scriptName = "sane_cast";
  passthru.extraWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    (lib.makeBinPath [ sane-cast xdg-terminal-exec ])
  ];
}
