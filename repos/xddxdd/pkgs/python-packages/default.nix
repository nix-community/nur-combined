{
  pkgs,
  _packages,
  createCallPackage,
  createLoadPackages,
  ...
}:
let
  callPackage = createCallPackage (_packages // pkgs.python3Packages // self);
  loadPackages = createLoadPackages callPackage;
  packages = loadPackages ./. { };

  self = packages // {
    data-recorder = packages.datarecorder;
    drission-record = packages.drissionrecord;
    drission-get = packages.drissionget;
    drission-page = packages.drissionpage;
    download-kit = packages.downloadkit;
    open-webui-kb-manager = packages.kb-manager;
    py-rcon = packages.rcon;
    runpod-python = packages.runpod;
  };
in
self
