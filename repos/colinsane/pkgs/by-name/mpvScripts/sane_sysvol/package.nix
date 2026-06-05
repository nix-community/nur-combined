{
  buildLua,  #< part of the mpvScripts scope
  lib,
  pipewire,
  sane-die-with-parent,
  wireplumber,
}:
buildLua {
  pname = "sane_sysvol";
  version = "0.1-unstable";
  src = ./.;

  preInstall = ''
    mkdir sane_sysvol
    mv main.lua sane_sysvol
    mv non_blocking_popen.lua sane_sysvol
  '';

  passthru.scriptName = "sane_sysvol";
  passthru.extraWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    (lib.makeBinPath [ pipewire sane-die-with-parent wireplumber ])
  ];
}

